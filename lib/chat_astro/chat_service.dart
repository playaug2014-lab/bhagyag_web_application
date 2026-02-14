import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'api_interface.dart';
import 'chat_models.dart';
import 'firebase_chat_screen.dart';

/// Chat Service - Handles all chat-related operations
/// Equivalent to the chat functionality in Kotlin's FirebaseChatAstrologer and Astrolog_detail
class ChatService {
  final ApiInterface _apiInterface = ApiInterface();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Post data to create/request chat session
  /// Equivalent to Kotlin's postdata() function
  Future<ChatModel?> requestChatSession({
    required String userId,
    required String astrologerId,
    int chatSessionId = 0,
  }) async {
    try {
      print('🔵 Requesting chat session...');
      print('🔵 User ID: $userId');
      print('🔵 Astrologer ID: $astrologerId');
      print('🔵 Chat Session ID: $chatSessionId');

      final request = RequestChat(
        astrologerId: astrologerId,
        chatSessionId: chatSessionId,
        userId: userId,
      );

      final chatModel = await _apiInterface.requestChatSession(request);

      print('✅ Chat session created successfully');
      print('✅ Message: ${chatModel.message}');
      print('✅ Chat Session ID: ${chatModel.record.chatSessionId}');
      print('✅ User ID: ${chatModel.record.userId}');
      print('✅ Astrologer ID: ${chatModel.record.astrologerId}');
      print('✅ Session Status: ${chatModel.record.sessionStatus}');
      print('✅ Start Date: ${chatModel.record.startDate}');

      return chatModel;
    } catch (e) {
      print('❌ Error requesting chat session: $e');
      return null;
    }
  }

  /// Check wallet and start chat if sufficient balance
  /// Equivalent to Kotlin's walletcheck() function
  Future<bool> checkWalletAndStartChat({
    required BuildContext context,
    required String userId,
    required String astrologerId,
    required String firebaseId,
    required String name,
    required String profileImage,
    required String status,
    required String aboutMe,
    required String specialized,
    required String language,
    required String rate,
    required String chargesPerMinute,
  }) async {
    try {
      print('🔵 Checking wallet balance...');

      // Deduct amount for chat
      final deductResponse = await _apiInterface.deductAmountForChat(
        userId,
        astrologerId,
      );

      if (deductResponse.success) {
        print('✅ Chat started successfully');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chat Started'),
              backgroundColor: Color(0xFF00C853),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to chat screen
          // You'll need to implement your chat screen navigation here
          _navigateToChatScreen(
            context: context,
            firebaseId: firebaseId,
            name: name,
            astrologerId: astrologerId,
            profileImage: profileImage,
            status: status,
            aboutMe: aboutMe,
            specialized: specialized,
            language: language,
            rate: rate,
            chargesPerMinute: chargesPerMinute,
          );
        }

        return true;
      } else {
        print('⚠️ Insufficient wallet balance');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'It looks like your wallet balance is too low for a 5-minute chat. Top it up to keep the conversation going!!!',
              ),
              backgroundColor: Color(0xFFFF7213),
              duration: Duration(seconds: 3),
            ),
          );
        }

        return false;
      }
    } catch (e) {
      print('❌ Error checking wallet: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    }
  }

  /// Get user status from Firebase
  /// Equivalent to Kotlin's getUserStatus() function
  Stream<String> getUserStatus(String firebaseId) {
    print('🔵 Getting user status for: $firebaseId');

    return _database
        .child('user')
        .child(firebaseId)
        .child('status')
        .onValue
        .map((event) {
      final status = event.snapshot.value?.toString() ?? 'offline';
      print('🔔 Status updated: $status');
      return status;
    }).handleError((error) {
      print('❌ Error getting user status: $error');
      return 'offline';
    });
  }

  /// Update user status in Firebase
  /// Equivalent to Kotlin's updatestatus() function
  Future<void> updateUserStatus(String uid, String status) async {
    try {
      print('🔵 Updating user status...');
      print('🔵 UID: $uid, Status: $status');

      await _database.child('user').child(uid).update({
        'uid': uid,
        'status': status,
      });

      print('✅ User status updated successfully');
    } catch (e) {
      print('❌ Failed to update user status: $e');
    }
  }

  /// Get wallet balance
  /// Equivalent to Kotlin's walletamount() function
  Future<double> getWalletBalance(String userId) async {
    try {
      print('🔵 Getting wallet balance for user: $userId');

      final walletBalance = await _apiInterface.getWalletBalance(userId);

      print('✅ Wallet balance: ₹${walletBalance.balance}');

      return walletBalance.balance;
    } catch (e) {
      print('❌ Error getting wallet balance: $e');
      return 0.0;
    }
  }

  /// Navigate to chat screen
  void _navigateToChatScreen({
    required BuildContext context,
    required String firebaseId,
    required String name,
    required String astrologerId,
    required String profileImage,
    required String status,
    required String aboutMe,
    required String specialized,
    required String language,
    required String rate,
    required String chargesPerMinute,
  }) {
    // TODO: Implement navigation to your chat screen
    // Example:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirebaseChatScreen(
          firebaseId: firebaseId,
          name: name,
          astrologerId: astrologerId,
          profileImage: profileImage,
          status: status,
          aboutMe: aboutMe,
          specialized: specialized,
          language: language,
          rate: rate,
          chargesPerMinute: chargesPerMinute,
        ),
      ),
    );

    print('🔵 Navigating to chat screen with:');
    print('   Firebase ID: $firebaseId');
    print('   Name: $name');
    print('   Astrologer ID: $astrologerId');
  }

  /// Check if user is logged in
  Future<bool> checkUserLogin(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';  // Changed from 'id' to 'userId'

      if (userId == '38cc683e-46bd-427e-a15a-08ddf834c0bc') {
        print('⚠️ User not logged in, navigating to login screen');

        if (context.mounted) {
          // Navigate to login screen
          // TODO: Implement your login screen navigation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to continue'),
              backgroundColor: Color(0xFFFF7213),
            ),
          );
        }

        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error checking user login: $e');
      return false;
    }
  }
}

/// Example usage in a widget
/// This shows how to integrate the ChatService into your Flutter app
class ChatServiceExample extends StatefulWidget {
  final String astrologerId;
  final String firebaseId;
  final String name;
  final String profileImage;

  const ChatServiceExample({
    Key? key,
    required this.astrologerId,
    required this.firebaseId,
    required this.name,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<ChatServiceExample> createState() => _ChatServiceExampleState();
}

class _ChatServiceExampleState extends State<ChatServiceExample> {
  final ChatService _chatService = ChatService();
  late StreamSubscription<String> _statusSubscription;
  String _currentStatus = 'offline';
  double _walletBalance = 0.0;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Get user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';  // Changed from 'id' to 'userId'

    if (_userId.isNotEmpty) {
      // Get wallet balance
      _walletBalance = await _chatService.getWalletBalance(_userId);
      setState(() {});

      // Listen to astrologer status
      _statusSubscription = _chatService
          .getUserStatus(widget.firebaseId)
          .listen((status) {
        setState(() {
          _currentStatus = status;
        });
      });

      // Request initial chat session
      await _chatService.requestChatSession(
        userId: _userId,
        astrologerId: widget.astrologerId,
        chatSessionId: 0,
      );
    }
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
  }

  Future<void> _startChat() async {
    final isLoggedIn = await _chatService.checkUserLogin(context);
    if (!isLoggedIn) return;

    if (_currentStatus.toLowerCase() == 'online') {
      await _chatService.checkWalletAndStartChat(
        context: context,
        userId: _userId,
        astrologerId: widget.astrologerId,
        firebaseId: widget.firebaseId,
        name: widget.name,
        profileImage: widget.profileImage,
        status: _currentStatus,
        aboutMe: '',
        specialized: '',
        language: '',
        rate: '',
        chargesPerMinute: '',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Astrologer is Offline'),
          backgroundColor: Color(0xFF797676),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _currentStatus.toLowerCase() == 'online';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Wallet Balance: ₹$_walletBalance'),
            const SizedBox(height: 20),
            Text('Status: $_currentStatus'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startChat,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isOnline ? const Color(0xFF00C853) : const Color(0xFF797676),
              ),
              child: const Text('Start Chat'),
            ),
          ],
        ),
      ),
    );
  }
}