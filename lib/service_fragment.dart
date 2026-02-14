// lib/screens/service_fragment.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/astro_chat_model.dart';
import '../astrologer/agora_video_call_screen.dart';
import '../voicecall/agora_voice_call_screen.dart'; // ✅ ADDED
import 'firebase_chat_screen.dart';

class ServiceFragment extends StatefulWidget {
  final String? userId;
  final String? firebaseUid;

  const ServiceFragment({
    Key? key,
    this.userId,
    this.firebaseUid,
  }) : super(key: key);

  @override
  State<ServiceFragment> createState() => ServiceFragmentState();
}

class ServiceFragmentState extends State<ServiceFragment> {
  bool _isChatEnabled = false;
  bool _isCallEnabled = false;
  bool _isVideoCallEnabled = false;

  String? _userName;
  String? _phoneNo;
  String? _uniqueId;
  String? _profileImage;
  String _totalEarning = '0.00';

  DatabaseReference? _dbRef;
  StreamSubscription<DatabaseEvent>? _userSub;
  Timer? _chatPollingTimer;

  static const String BASE_URL = "https://test.bhagyag.com";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToFirebase();
  }

  @override
  void didUpdateWidget(ServiceFragment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.firebaseUid != widget.firebaseUid) {
      _loadUserData();
      _listenToFirebase();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('fullName');
      _phoneNo = prefs.getString('phoneNo');
      _uniqueId = prefs.getString('uniqueUserID');
      _profileImage = prefs.getString('profileImage');
    });

    if (widget.userId != null) {
      await _fetchTotalEarnings(widget.userId!);
    }
  }

  Future<void> _fetchTotalEarnings(String astrologerId) async {
    try {
      final url = Uri.parse(
          '$BASE_URL/api/WalletTransaction/GetAstrologerReport/$astrologerId');
      final response =
      await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalEarning = (data['payableAmount'] ?? 0).toString();
        });
        debugPrint('✅ Total earning loaded: $_totalEarning');
      }
    } catch (e) {
      debugPrint('❌ Earnings fetch error: $e');
    }
  }

  void _listenToFirebase() {
    _userSub?.cancel();

    if (widget.firebaseUid == null) return;

    _dbRef = FirebaseDatabase.instance.ref('user/${widget.firebaseUid}');

    _userSub = _dbRef!.onValue.listen((event) {
      if (!event.snapshot.exists || !mounted) return;

      final value = event.snapshot.value;
      if (value is! Map) return;

      final data = Map<dynamic, dynamic>.from(value as Map);

      final type = data['type']?.toString();
      final videoCall = data['videocall']?.toString();
      final voiceCall = data['voicecall']?.toString();

      if (type == 'enable' && videoCall == 'on') {
        _showIncomingCallDialog('Video Call');
      } else if (type == 'enable' && voiceCall == 'on') {
        _showIncomingCallDialog('Voice Call');
      }
    });
  }

  void _showIncomingCallDialog(String callType) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              callType == 'Video Call' ? Icons.videocam : Icons.call,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(width: 8),
            Text('Incoming $callType'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Someone is calling you',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Pulsing animation for visual effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    callType == 'Video Call'
                        ? Icons.videocam
                        : Icons.phone_in_talk,
                    color: Colors.green,
                    size: 48,
                  ),
                );
              },
              onEnd: () {
                // Loop animation
                if (mounted) setState(() {});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _declineCall(callType);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call_end, size: 20),
                SizedBox(width: 4),
                Text('Decline'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleAcceptCall(callType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call, size: 20),
                SizedBox(width: 4),
                Text('Accept'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAcceptCall(String callType) {
    debugPrint('✅ Accepting $callType');

    if (callType == 'Video Call') {
      // Navigate to video call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VideoCallScreen(
            isAstrologer: true,
          ),
        ),
      ).then((_) {
        // Reset Firebase status after call ends
        _resetCallState();
      });
    } else if (callType == 'Voice Call') {
      // ✅ Navigate to voice call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoiceCallScreen(
            isAstrologer: true,
            userName: _userName, // Astrologer's name
            userFirebaseId: widget.firebaseUid, // For Firebase updates
            astrologerId: widget.userId, // For API calls if needed
          ),
        ),
      ).then((_) {
        // Reset Firebase status after call ends
        _resetCallState();
      });
    }
  }

  void _resetCallState() {
    // Update Firebase to clear call state
    if (widget.firebaseUid != null) {
      final ref = FirebaseDatabase.instance.ref('user/${widget.firebaseUid}');
      ref.update({
        'type': 'disable',
        'videocall': 'offline',
        'voicecall': 'offline',
      });
    }

    debugPrint('✅ Call state reset');
  }

  void _declineCall(String callType) {
    debugPrint('❌ Declined $callType');

    // Update Firebase to indicate call was declined
    if (widget.firebaseUid != null) {
      final ref = FirebaseDatabase.instance.ref('user/${widget.firebaseUid}');
      ref.update({
        'type': 'disable',
        'videocall': 'offline',
        'voicecall': 'offline',
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$callType declined'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _startChatPolling() {
    _stopChatPolling();

    if (widget.userId == null) return;

    _chatPollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchAstroChat(widget.userId!);
    });

    debugPrint('✅ Chat polling started');
  }

  void _stopChatPolling() {
    _chatPollingTimer?.cancel();
    _chatPollingTimer = null;
    debugPrint('⏹️ Chat polling stopped');
  }

  Future<void> _fetchAstroChat(String astrologerId) async {
    try {
      final url = Uri.parse(
          '$BASE_URL/api/Chat/GetAstrologerChat?AstrologerID=$astrologerId');
      final response =
      await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final astroChat = AstroChat.fromJson(jsonDecode(response.body));

        if (astroChat.record.isNotEmpty) {
          final filteredData = astroChat.record
              .where((user) => user.fullName.isNotEmpty)
              .toList();

          if (filteredData.isNotEmpty && mounted) {
            _showChatRequestDialog(filteredData.first);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Fetch astro chat error: $e');
    }
  }

  void _showChatRequestDialog(UserChatDetail user) {
    if (!mounted) return;

    _stopChatPolling();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.chat_bubble, color: Colors.blue),
            SizedBox(width: 8),
            Text('New Chat Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User wants to chat with you'),
            const SizedBox(height: 8),
            Text(
              'User ID: ${user.userId}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_isChatEnabled) {
                _startChatPolling();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleAcceptChat(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  void _handleAcceptChat(UserChatDetail user) {
    debugPrint('✅ Accepting chat from user: ${user.userId}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirebaseChatScreen(
          userId: user.userId,
          userName: user.fullName,
          userFirebaseId: user.firebaseID,
          userProfileImage: user.profileImage,
          astrologerId: widget.userId!,
        ),
      ),
    ).then((_) {
      if (_isChatEnabled && mounted) {
        _startChatPolling();
      }
    });
  }

  Future<void> _updateFirebaseStatus(String key, String value) async {
    if (widget.firebaseUid == null) return;

    final ref = FirebaseDatabase.instance.ref('user/${widget.firebaseUid}');
    await ref.update({key: value});

    debugPrint('✅ Firebase updated: $key = $value');
  }

  Future<void> _updateStatus(String status, String comswitch) async {
    if (widget.firebaseUid == null) return;

    final ref = FirebaseDatabase.instance.ref('user/${widget.firebaseUid}');
    await ref.update({
      'uid': widget.firebaseUid,
      'status': status,
      'comswitch': comswitch,
    });

    if (widget.userId != null) {
      await _updateAstroOnlineTime(widget.userId!, comswitch);
    }

    debugPrint('✅ Status updated: status=$status, comswitch=$comswitch');
  }

  Future<void> _updateAstroOnlineTime(String userId, String newStatus) async {
    try {
      final url = Uri.parse(
          '$BASE_URL/api/AstrologerOnlineTimes?userId=$userId&newStatus=$newStatus');
      final response =
      await http.post(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Astro online time updated');
      }
    } catch (e) {
      debugPrint('❌ Update astro time error: $e');
    }
  }

  void _checkAndSetOnlineStatus() {
    if (_isChatEnabled) {
      _updateStatus('online', 'online');
    } else if (_isCallEnabled || _isVideoCallEnabled) {
      _updateStatus('offline', 'online');
    } else {
      _updateStatus('offline', 'offline');
    }
  }

  void _checkAndSetOfflineStatus() {
    if (_isChatEnabled) {
      _updateStatus('online', 'online');
    } else if (_isCallEnabled || _isVideoCallEnabled) {
      _updateStatus('offline', 'online');
    } else {
      _updateStatus('offline', 'offline');
    }
  }

  // ✅ PUBLIC METHODS - Can be called from dashboard
  bool isAnyServiceOn() {
    return _isChatEnabled || _isCallEnabled || _isVideoCallEnabled;
  }

  void turnOffAllServices() {
    if (!mounted) return;

    setState(() {
      _isChatEnabled = false;
      _isCallEnabled = false;
      _isVideoCallEnabled = false;
    });
    _stopChatPolling();
    _updateStatus('offline', 'offline');

    debugPrint('✅ All services turned off');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bhagyag Panel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFD6E62),
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildServiceSwitches(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 43,
              backgroundColor: Colors.grey.shade300,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: _profileImage != null &&
                    _profileImage!.isNotEmpty
                    ? NetworkImage('$BASE_URL/files/profile/$_profileImage')
                    : null,
                child: _profileImage == null || _profileImage!.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName ?? 'Username',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _uniqueId ?? 'Astrologer ID',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phoneNo ?? 'Phone',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Total Earning: $_totalEarning',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Service charge, TDS will be applied on your total earning amount.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSwitches() {
    return Column(
      children: [
        _buildServiceSwitch(
          icon: Icons.chat,
          label: 'Chat',
          value: _isChatEnabled,
          onChanged: (value) {
            setState(() => _isChatEnabled = value);

            if (value) {
              _startChatPolling();
              _updateStatus('online', 'online');
            } else {
              _stopChatPolling();
              _checkAndSetOfflineStatus();
            }
          },
        ),
        const Divider(height: 1),
        _buildServiceSwitch(
          icon: Icons.call,
          label: 'Call',
          value: _isCallEnabled,
          onChanged: (value) {
            setState(() => _isCallEnabled = value);
            _updateFirebaseStatus('voicecall', value ? 'online' : 'offline');
            _checkAndSetOnlineStatus();
          },
        ),
        const Divider(height: 1),
        _buildServiceSwitch(
          icon: Icons.videocam,
          label: 'Video Call',
          value: _isVideoCallEnabled,
          onChanged: (value) {
            setState(() => _isVideoCallEnabled = value);
            _updateFirebaseStatus('videocall', value ? 'online' : 'offline');
            _checkAndSetOnlineStatus();
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.all_inclusive, color: Colors.green),
          title: const Text(
            'Unlimited Free Calls & Chats',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Switch(
            value: true,
            onChanged: null,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFFFD6E62)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFD6E62),
    );
  }

  @override
  void dispose() {
    _stopChatPolling();
    _userSub?.cancel();

    if (widget.firebaseUid != null) {
      _updateStatus('offline', 'offline');
    }

    super.dispose();
  }
}