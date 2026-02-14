// lib/astrologer/agora_video_call_screen.dart
// ✅ iOS + Android VIDEO CALL IMPLEMENTATION (Matching Android Architecture)
// ✅ FIXED: UID + TOKEN FLOW (no uid = 0, single UID used everywhere)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../astrologer/agora_service.dart';
import '../astrologer/agora_config.dart';

class VideoCallScreen extends StatefulWidget {
  final String? channelName;
  final bool isAstrologer; // true for astrologer, false for user

  const VideoCallScreen({
    Key? key,
    this.channelName,
    this.isAstrologer = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // ✅ Agora Engine
  RtcEngine? _engine;

  // ✅ State variables (matching Android)
  int? _localUid;         // The UID used for token + join + recording
  int? _remoteUid;        // Remote user's UID
  bool _isJoined = false;
  bool _recordingStarted = false;
  String? _recordingSid;
  String? _token;
  bool _isFrontCamera = true; // Track camera state
  bool _isPreviewReady = false; // Track if preview has started

  // ✅ Timer for call duration (matching Android's 5-minute countdown)
  Timer? _callTimer;
  int _timeLeftInSeconds = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  @override
  void dispose() {
    _disposeAgora();
    super.dispose();
  }

  // ✅ Initialize Agora (matching Android's setupVideoSDKEngine)
  Future<void> _initializeAgora() async {
    // 1. Permissions
    if (!await _checkPermissions()) {
      await _requestPermissions();
      if (!await _checkPermissions()) {
        _showMessage('Permissions not granted');
        return;
      }
    }

    try {
      // 2. Create engine
      _engine = createAgoraRtcEngine();

      await _engine!.initialize(
        const RtcEngineContext(
          appId: AgoraConfig.APP_ID,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // 3. Event handlers (matching Android's mRtcEventHandler)
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('✅ Joined Channel: ${connection.channelId}');
            print('   Local UID from engine: ${connection.localUid}');

            setState(() {
              _isJoined = true;

              // If engine reports 0, keep our own UID
              if (connection.localUid != 0) {
                _localUid = connection.localUid;
              }
            });

            _startCallTimer();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('👤 Remote user joined: $remoteUid');
            setState(() {
              _remoteUid = remoteUid;
            });

            // ✅ Start recording when remote user joins (same as Android)
            if (!_recordingStarted && _token != null && _localUid != null) {
              _startRecording();
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            print('👋 Remote user offline: $remoteUid (reason: $reason)');
            setState(() {
              _remoteUid = null;
            });
          },
          onError: (ErrorCodeType err, String msg) {
            print('❌ Agora Error: $err - $msg');
            if (err == ErrorCodeType.errInvalidToken) {
              _showMessage('Invalid Token Error - Please regenerate token');
            } else if (err == ErrorCodeType.errTokenExpired) {
              _showMessage('Token Expired - Please refresh');
            }
          },
        ),
      );

      // 4. Enable video + configure camera settings
      await _engine!.enableVideo();

      // ✅ Set video encoder configuration for better quality
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 0, // Standard bitrate
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      // ✅ Switch to front camera (default is back camera on mobile)
      await _engine!.switchCamera();

      // ✅ Start preview
      await _engine!.startPreview();

      // Mark preview as ready
      setState(() {
        _isPreviewReady = true;
      });

      print('✅ Camera preview started');

      // 5. Prepare & join channel (token + UID)
      await _prepareAndJoinChannel();
    } catch (e) {
      print('❌ Agora initialization error: $e');
      _showMessage('Failed to initialize: $e');
    }
  }

  // ✅ Prepare token + UID and join channel (get both from server)
  Future<void> _prepareAndJoinChannel() async {
    try {
      final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

      print('🔄 Fetching token and UID from server...');

      // ✅ NEW API: Get both UID and token from server
      final result = await AgoraService.getTokenAndUidFromServer(
        channelName: channelName,
      );

      if (result == null) {
        _showMessage('Failed to get token and UID from server');
        return;
      }

      final uid = result['uid'] as int;
      final token = result['token'] as String;

      if (token.isEmpty || uid <= 0) {
        _showMessage('Invalid token or UID from server');
        return;
      }

      setState(() {
        _token = token;
        _localUid = uid; // ✅ Use UID from server
      });

      print('🎯 Joining channel...');
      print('   Channel: $channelName');
      print('   UID (from server): $uid');
      print('   Token: ${token.substring(0, 10)}...${token.substring(token.length - 10)}');

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid, // ✅ Use server-provided UID
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          // publishLocalAudio: true,
          // publishLocalVideo: true,
        ),
      );
    } catch (e) {
      print('❌ Join channel error: $e');
      _showMessage('Failed to join channel: $e');
    }
  }

  // ✅ Start Recording (matching Android's record() method)
  Future<void> _startRecording() async {
    if (_recordingStarted) {
      print('⚠️ Recording already started');
      return;
    }

    if (_localUid == null || _token == null) {
      print('❌ Cannot start recording - UID or token is null');
      return;
    }

    try {
      final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

      print('🎥 Starting recording...');
      print('   Channel: $channelName');
      print('   UID: $_localUid');
      print('   Token length: ${_token!.length}');

      final sid = await AgoraService.startRecording(
        channelName: channelName,
        uid: _localUid!,
        token: _token!,
      );

      if (sid != null) {
        setState(() {
          _recordingStarted = true;
          _recordingSid = sid;
        });
        print('✅ Recording started with SID: $sid');
      } else {
        print('❌ Failed to start recording');
      }
    } catch (e) {
      print('❌ Start recording error: $e');
    }
  }

  // ✅ Stop Recording
  Future<void> _stopRecording() async {
    if (!_recordingStarted || _recordingSid == null || _localUid == null) {
      return;
    }

    try {
      final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

      print('⏹️ Stopping recording...');
      final success = await AgoraService.stopRecording(
        channelName: channelName,
        uid: _localUid!,
        sid: _recordingSid!,
      );

      if (success) {
        setState(() {
          _recordingStarted = false;
          _recordingSid = null;
        });
        print('✅ Recording stopped');
      } else {
        print('❌ Recording stop failed');
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
    }
  }

  // ✅ Leave Channel (matching Android's leaveChannel)
  Future<void> _leaveChannel() async {
    try {
      // Stop recording first
      if (_recordingStarted) {
        await _stopRecording();
      }

      // Stop preview and leave
      await _engine?.stopPreview();
      await _engine?.leaveChannel();

      setState(() {
        _isJoined = false;
        _remoteUid = null;
        _localUid = null;
      });

      print('👋 Left channel');

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Leave channel error: $e');
    }
  }

  // ✅ Dispose Agora (matching Android's onDestroy)
  Future<void> _disposeAgora() async {
    try {
      _callTimer?.cancel();

      if (_recordingStarted) {
        await _stopRecording();
      }

      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();

      _engine = null;
    } catch (e) {
      print('❌ Dispose error: $e');
    }
  }

  // ✅ Switch between front and back camera
  Future<void> _switchCamera() async {
    try {
      await _engine?.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
      print('📷 Switched to ${_isFrontCamera ? "front" : "back"} camera');
    } catch (e) {
      print('❌ Camera switch error: $e');
    }
  }

  // ✅ Start call timer (matching Android's countdown)
  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeftInSeconds > 0) {
        setState(() {
          _timeLeftInSeconds--;
        });
      } else {
        _leaveChannel();
      }
    });
  }

  // ✅ Permission handling
  Future<bool> _checkPermissions() async {
    final camera = await Permission.camera.isGranted;
    final microphone = await Permission.microphone.isGranted;
    return camera && microphone;
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // ✅ Format timer display
  String _formatTime() {
    final minutes = _timeLeftInSeconds ~/ 60;
    final seconds = _timeLeftInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ Remote video (full screen)
            if (_remoteUid != null)
              SizedBox.expand(
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine!,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: channelName),
                  ),
                ),
              )
            else
              const Center(
                child: Text(
                  'Waiting for remote user...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

            // ✅ Local video (small preview - top right)
            if (_isPreviewReady)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine!,
                        canvas: const VideoCanvas(uid: 0), // ✅ uid: 0 for local user
                      ),
                    ),
                  ),
                ),
              ),

            // ✅ Timer display (top center)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTime(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Recording indicator
            if (_recordingStarted)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'REC',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            // ✅ Bottom controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera switch button
                  FloatingActionButton(
                    heroTag: 'camera',
                    backgroundColor: Colors.white,
                    onPressed: _switchCamera,
                    child: Icon(
                      _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                      color: Colors.black,
                    ),
                  ),
                  // Leave button
                  FloatingActionButton(
                    heroTag: 'leave',
                    backgroundColor: Colors.red,
                    onPressed: _leaveChannel,
                    child: const Icon(Icons.call_end),
                  ),
                  // Placeholder for symmetry
                  const SizedBox(width: 56),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}