// lib/astrologer/agora_voice_call_screen.dart
// ✅ iOS + Android VOICE CALL IMPLEMENTATION (Matching Video Call Architecture)
// ✅ SAME API: Same channel name, token, and recording system as video call
// ✅ Audio-only optimization with visual UI feedback

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import '../astrologer/agora_service.dart';
import '../astrologer/agora_config.dart';

class VoiceCallScreen extends StatefulWidget {
  final String? channelName;
  final bool isAstrologer; // true for astrologer, false for user
  final String? userName; // Optional: Display name for the caller (local user)
  final String? remoteUserName; // Optional: Display name for remote user
  final String? userFirebaseId; // Firebase UID of the user calling
  final String? astrologerId; // Astrologer ID for API calls

  const VoiceCallScreen({
    Key? key,
    this.channelName,
    this.isAstrologer = false,
    this.userName,
    this.remoteUserName,
    this.userFirebaseId,
    this.astrologerId,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  // ✅ Agora Engine
  RtcEngine? _engine;

  // ✅ State variables (identical to video call)
  int? _localUid; // The UID used for token + join + recording
  int? _remoteUid; // Remote user's UID
  bool _isJoined = false;
  bool _recordingStarted = false;
  String? _recordingSid;
  String? _token;
  bool _isMuted = false; // Microphone mute state
  bool _isSpeakerOn = true; // Speaker state (true = loudspeaker, false = earpiece)

  // ✅ Timer for call duration (same as video call - 5 minutes)
  Timer? _callTimer;
  int _timeLeftInSeconds = 300; // 5 minutes

  // ✅ Animation for audio wave effect
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeAgora();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disposeAgora();
    super.dispose();
  }

  // ✅ Initialize animation for audio wave effect
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // ✅ Initialize Agora for VOICE CALL (audio-only)
  Future<void> _initializeAgora() async {
    print('🎙️ Starting voice call initialization...');

    // 1. Check permissions (microphone only for voice call)
    print('   Step 1: Checking microphone permission...');
    if (!await _checkPermissions()) {
      print('   ⚠️ Microphone permission not granted, requesting...');
      await _requestPermissions();
      if (!await _checkPermissions()) {
        print('   ❌ Microphone permission denied by user');
        _showMessage('Microphone permission not granted');
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
    }
    print('   ✅ Microphone permission granted');

    try {
      // 2. Create engine
      print('   Step 2: Creating RTC engine...');
      _engine = createAgoraRtcEngine();
      print('   ✅ RTC engine created');

      print('   Step 3: Initializing engine with App ID...');
      await _engine!.initialize(
        const RtcEngineContext(
          appId: AgoraConfig.APP_ID,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      print('   ✅ Engine initialized');

      // 3. Event handlers (same as video call)
      print('   Step 4: Registering event handlers...');
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('✅ Joined Voice Channel: ${connection.channelId}');
            print('   Local UID from engine: ${connection.localUid}');

            setState(() {
              _isJoined = true;

              // If engine reports 0, keep our own UID
              if (connection.localUid != 0) {
                _localUid = connection.localUid;
              }
            });

            // ✅ Enable speaker AFTER joining channel
            _engine?.setEnableSpeakerphone(true).then((_) {
              print('✅ Speaker enabled');
            }).catchError((e) {
              print('⚠️ Speaker enable warning: $e');
            });

            _startCallTimer();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print('👤 Remote user joined voice call: $remoteUid');
            setState(() {
              _remoteUid = remoteUid;
            });

            // ✅ Start recording when remote user joins (same as video call)
            if (!_recordingStarted && _token != null && _localUid != null) {
              _startRecording();
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
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
          // ✅ Audio volume indicator (for visual feedback)
          onAudioVolumeIndication: (RtcConnection connection,
              List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
            // You can use this to show audio level indicators if needed
            if (speakers.isNotEmpty) {
              for (var speaker in speakers) {
                if (speaker.uid == 0) {
                  // Local user speaking
                } else {
                  // Remote user speaking
                }
              }
            }
          },
        ),
      );
      print('   ✅ Event handlers registered');

      // 4. ✅ CRITICAL: Enable AUDIO only (no video for voice call)
      print('   Step 5: Configuring audio settings...');
      await _engine!.enableAudio();
      print('   ✅ Audio enabled');

      await _engine!.disableVideo(); // Explicitly disable video
      print('   ✅ Video disabled');

      // 5. ✅ Set audio profile for voice call quality
      await _engine!.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioGameStreaming,
      );
      print('   ✅ Audio profile set');

      // 6. ✅ Enable audio volume indication for UI feedback
      await _engine!.enableAudioVolumeIndication(
        interval: 300, // Update every 300ms
        smooth: 3,
        reportVad: true,
      );
      print('   ✅ Audio volume indication enabled');

      print('✅ Voice call audio initialized successfully');

      // 7. Prepare & join channel (token + UID)
      print('   Step 6: Preparing to join channel...');
      await _prepareAndJoinChannel();
    } catch (e, stackTrace) {
      print('❌ Agora voice initialization error: $e');
      print('   Stack trace: $stackTrace');
      _showMessage('Failed to initialize voice call: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ✅ Prepare token + UID and join channel (SAME AS VIDEO CALL)
  Future<void> _prepareAndJoinChannel() async {
    try {
      final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

      print('🔄 Fetching token and UID from server for voice call...');
      print('   Channel: $channelName');

      // ✅ SAME API: Get both UID and token from server
      final result = await AgoraService.getTokenAndUidFromServer(
        channelName: channelName,
      );

      if (result == null) {
        print('❌ Failed to get token and UID from server');
        _showMessage('Failed to connect to server. Please check your internet connection.');
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      final uid = result['uid'] as int;
      final token = result['token'] as String;

      if (token.isEmpty || uid <= 0) {
        print('❌ Invalid token or UID from server');
        print('   UID: $uid');
        print('   Token: ${token.isEmpty ? "empty" : "received"}');
        _showMessage('Invalid server response. Please try again.');
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      setState(() {
        _token = token;
        _localUid = uid; // ✅ Use UID from server
      });

      print('🎯 Joining voice channel...');
      print('   Channel: $channelName');
      print('   UID (from server): $uid');
      print('   Token: ${token.substring(0, 10)}...${token.substring(token.length - 10)}');

      // ✅ Small delay to ensure engine is fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid, // ✅ Use server-provided UID
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishMicrophoneTrack: true, // ✅ Audio only
          publishCameraTrack: false, // ✅ No video
          autoSubscribeAudio: true, // ✅ Subscribe to remote audio
        ),
      );

      print('✅ Join channel request sent');
    } catch (e, stackTrace) {
      print('❌ Join voice channel error: $e');
      print('   Stack trace: $stackTrace');
      _showMessage('Failed to join voice channel: $e');
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ✅ Start Recording (SAME AS VIDEO CALL but with 'audio' mode)
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

      print('🎙️ Starting audio recording...');
      print('   Channel: $channelName');
      print('   UID: $_localUid');
      print('   Token length: ${_token!.length}');

      // ✅ Use 'audio' recording mode instead of 'video'
      final sid = await AgoraService.startRecording(
        channelName: channelName,
        uid: _localUid!,
        token: _token!,
        recordingMode: 'audio', // ✅ AUDIO recording mode
      );

      if (sid != null) {
        setState(() {
          _recordingStarted = true;
          _recordingSid = sid;
        });
        print('✅ Audio recording started with SID: $sid');
      } else {
        print('❌ Failed to start audio recording');
      }
    } catch (e) {
      print('❌ Start audio recording error: $e');
    }
  }

  // ✅ Stop Recording (SAME AS VIDEO CALL)
  Future<void> _stopRecording() async {
    if (!_recordingStarted || _recordingSid == null || _localUid == null) {
      return;
    }

    try {
      final channelName = widget.channelName ?? AgoraConfig.CHANNEL_NAME;

      print('⏹️ Stopping audio recording...');
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
        print('✅ Audio recording stopped');
      } else {
        print('❌ Audio recording stop failed');
      }
    } catch (e) {
      print('❌ Stop audio recording error: $e');
    }
  }

  // ✅ Leave Channel (SAME AS VIDEO CALL)
  Future<void> _leaveChannel() async {
    try {
      // Stop recording first
      if (_recordingStarted) {
        await _stopRecording();
      }

      // Update Firebase before leaving (if astrologer)
      if (widget.isAstrologer && widget.userFirebaseId != null) {
        await _updateFirebaseCallStatus('offline');
      }

      // Leave channel
      await _engine?.leaveChannel();

      setState(() {
        _isJoined = false;
        _remoteUid = null;
        _localUid = null;
      });

      print('👋 Left voice channel');

      // Navigate back
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Leave voice channel error: $e');
      // Still try to navigate back even if there's an error
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ✅ Dispose Agora
  Future<void> _disposeAgora() async {
    try {
      _callTimer?.cancel();

      if (_recordingStarted) {
        await _stopRecording();
      }

      await _engine?.leaveChannel();
      await _engine?.release();

      _engine = null;

      // ✅ Update Firebase status when leaving (if astrologer)
      if (widget.isAstrologer && widget.userFirebaseId != null) {
        await _updateFirebaseCallStatus('offline');
      }
    } catch (e) {
      print('❌ Dispose error: $e');
    }
  }

  // ✅ Update Firebase call status
  Future<void> _updateFirebaseCallStatus(String status) async {
    if (widget.userFirebaseId == null) return;

    try {
      final ref = FirebaseDatabase.instance.ref('user/${widget.userFirebaseId}');
      await ref.update({
        'voicecall': status,
        'type': status == 'online' ? 'enable' : 'disable',
      });
      print('✅ Firebase voice call status updated: $status');
    } catch (e) {
      print('❌ Firebase update error: $e');
    }
  }

  // ✅ Toggle microphone mute
  Future<void> _toggleMute() async {
    try {
      await _engine?.muteLocalAudioStream(!_isMuted);
      setState(() {
        _isMuted = !_isMuted;
      });
      print('🎤 Microphone ${_isMuted ? "muted" : "unmuted"}');
    } catch (e) {
      print('❌ Mute toggle error: $e');
    }
  }

  // ✅ Toggle speaker (loudspeaker vs earpiece)
  Future<void> _toggleSpeaker() async {
    if (!_isJoined) {
      print('⚠️ Cannot toggle speaker: Not joined to channel yet');
      return;
    }

    try {
      await _engine?.setEnableSpeakerphone(!_isSpeakerOn);
      setState(() {
        _isSpeakerOn = !_isSpeakerOn;
      });
      print('🔊 Speaker ${_isSpeakerOn ? "on" : "off"}');
    } catch (e) {
      print('❌ Speaker toggle error: $e');
    }
  }

  // ✅ Start call timer (SAME AS VIDEO CALL)
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

  // ✅ Permission handling (microphone only)
  Future<bool> _checkPermissions() async {
    return await Permission.microphone.isGranted;
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
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
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Stack(
          children: [
            // ✅ Main content
            Column(
              children: [
                // ✅ Timer display (top)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      _formatTime(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // ✅ Avatar section with animated audio wave
                Column(
                  children: [
                    // Remote user avatar with animation when connected
                    if (_remoteUid != null) ...[
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C63FF).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.remoteUserName ?? 'Connected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_in_talk,
                                color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'In Call',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Waiting state
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 60,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Waiting for user...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white54),
                        ),
                      ),
                    ],
                  ],
                ),

                const Spacer(),

                // ✅ Control buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute button
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        backgroundColor: _isMuted ? Colors.red : Colors.white,
                        iconColor: _isMuted ? Colors.white : Colors.black,
                        onPressed: _toggleMute,
                      ),

                      // End call button
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'End Call',
                        backgroundColor: Colors.red,
                        iconColor: Colors.white,
                        isLarge: true,
                        onPressed: _leaveChannel,
                      ),

                      // Speaker button
                      _buildControlButton(
                        icon: _isSpeakerOn
                            ? Icons.volume_up
                            : Icons.hearing,
                        label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                        backgroundColor: _isSpeakerOn
                            ? const Color(0xFF6C63FF)
                            : Colors.white,
                        iconColor: _isSpeakerOn ? Colors.white : Colors.black,
                        onPressed: _toggleSpeaker,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),

            // ✅ Recording indicator (top left)
            if (_recordingStarted)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 12),
                      SizedBox(width: 6),
                      Text(
                        'RECORDING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ✅ Connection status (top right)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isJoined
                      ? Colors.green.withOpacity(0.9)
                      : Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isJoined ? Icons.check_circle : Icons.hourglass_empty,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isJoined ? 'Connected' : 'Connecting...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper to build control buttons
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    final size = isLarge ? 70.0 : 60.0;
    final iconSize = isLarge ? 32.0 : 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          elevation: 8,
          shadowColor: backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(size / 2),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size / 2),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}