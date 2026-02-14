import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'chat_service.dart';
import 'api_interface.dart';
import 'chat_models.dart';

/// Firebase Chat Screen - Equivalent to FirebaseChatAstrologer.kt
class FirebaseChatScreen extends StatefulWidget {
  final String firebaseId;       // firebasseid
  final String name;             // name
  final String astrologerId;     // msg
  final String profileImage;     // profilimage
  final String status;           // status
  final String aboutMe;          // aboutme
  final String specialized;      // specialized
  final String language;         // language
  final String rate;             // rate
  final String chargesPerMinute; // chargesPerMinutes

  const FirebaseChatScreen({
    Key? key,
    required this.firebaseId,
    required this.name,
    required this.astrologerId,
    required this.profileImage,
    required this.status,
    required this.aboutMe,
    required this.specialized,
    required this.language,
    required this.rate,
    required this.chargesPerMinute,
  }) : super(key: key);

  @override
  State<FirebaseChatScreen> createState() => _FirebaseChatScreenState();
}

class _FirebaseChatScreenState extends State<FirebaseChatScreen> {
  // Services and references
  final ChatService _chatService = ChatService();
  final ApiInterface _apiInterface = ApiInterface();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _messageController = TextEditingController();

  // State variables
  List<Message> _messages = [];
  String _senderRoom = '';
  String _receiverRoom = '';
  String? _firebaseUserId;
  String _userId = '';
  int _chatSessionId = 0;

  // Timer for 5-minute countdown
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes = 300 seconds

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      print('🔵 Initializing chat screen...');

      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId') ?? '';

      // Get Firebase user ID
      _firebaseUserId = FirebaseAuth.instance.currentUser?.uid;

      if (_firebaseUserId == null) {
        print('❌ Firebase user not authenticated');
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      print('✅ User ID: $_userId');
      print('✅ Firebase UID: $_firebaseUserId');

      // Setup chat rooms (Kotlin: senderroom = reciveruid + senderuid)
      _senderRoom = '${widget.firebaseId}$_firebaseUserId';
      _receiverRoom = '$_firebaseUserId${widget.firebaseId}';

      print('✅ Sender Room: $_senderRoom');
      print('✅ Receiver Room: $_receiverRoom');

      // Update Firebase ID on server (Kotlin: Firebaseidup())
      await _updateFirebaseIdOnServer();

      // Update user status to online
      await _chatService.updateUserStatus(_firebaseUserId!, 'online');

      // Request chat session (Kotlin: postdata())
      final chatModel = await _chatService.requestChatSession(
        userId: _userId,
        astrologerId: widget.astrologerId,
        chatSessionId: 0,
      );

      if (chatModel != null) {
        _chatSessionId = chatModel.record.chatSessionId;
        print('✅ Chat Session ID: $_chatSessionId');
      }

      // Listen to messages
      _listenToMessages();

      // Start countdown timer
      _startCountdown();

      setState(() {});
    } catch (e) {
      print('❌ Error initializing chat: $e');
    }
  }

  /// Update Firebase ID on server (Kotlin: Firebaseidup())
  Future<void> _updateFirebaseIdOnServer() async {
    try {
      print('🔵 Updating Firebase ID on server...');

      await _apiInterface.updateFirebaseId(
        userId: _userId,
        firebaseId: _firebaseUserId!,
        chatStatus: 'Online',
      );

      print('✅ Firebase ID updated on server');
    } catch (e) {
      print('❌ Error updating Firebase ID: $e');
      // Don't throw - this is not critical for chat to work
    }
  }

  /// Listen to Firebase messages (Kotlin: addValueEventListener)
  void _listenToMessages() {
    _database
        .child('chats')
        .child(_senderRoom)
        .child('messages')
        .onValue
        .listen((event) {
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final messagesMap = Map<String, dynamic>.from(snapshot.value as Map);

        final messagesList = <Message>[];
        messagesMap.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value);
          messagesList.add(Message.fromJson(messageData));
        });

        // Sort by timestamp
        messagesList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          _messages = messagesList;
        });

        // Scroll to bottom
        _scrollToBottom();
      }
    });
  }

  /// Send text message (Kotlin: sendbutton.setOnClickListener)
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) return;

    try {
      print('🔵 Sending message: $messageText');

      // Mask phone numbers (Kotlin: msknumber())
      final maskedMessage = _maskPhoneNumbers(messageText);

      // Get current timestamp in local time WITHOUT Z: "2025-12-18T13:22:21.523137"
      final timestamp = DateTime.now().toIso8601String().replaceAll('Z', '');

      print('📅 Timestamp: $timestamp');

      // Create message object
      final message = Message(
        message: maskedMessage,
        senderId: _firebaseUserId,
        timestamp: timestamp,
        imageUrl: null,
      );

      // Send to Firebase (sender room)
      await _database
          .child('chats')
          .child(_senderRoom)
          .child('messages')
          .push()
          .set(message.toJson());

      // Send to Firebase (receiver room)
      await _database
          .child('chats')
          .child(_receiverRoom)
          .child('messages')
          .push()
          .set(message.toJson());

      // Send to API server (Kotlin: sendchat())
      await _sendMessageToApi(maskedMessage, timestamp);

      // Clear input
      _messageController.clear();

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send message to API (Kotlin: sendchat())
  Future<void> _sendMessageToApi(String messageText, String timestamp) async {
    try {
      print('🔵 Sending message to API...');
      print('   Chat Session ID: $_chatSessionId');
      print('   Message: $messageText');

      final request = RequestSendChat(
        chatId: 0,
        chatSessionId: _chatSessionId,
        senderId: _userId,
        messageText: messageText,
        msgType: 'string',
        sentOn: timestamp,
      );

      final response = await _apiInterface.sendChatMessage(request);

      print('✅ Message sent to API: ${response.message}');
      print('✅ Chat ID: ${response.record.chatId}');
      print('✅ Chat Session ID: ${response.record.chatSessionId}');
    } catch (e) {
      print('❌ Error sending message to API: $e');
    }
  }

  /// Mask phone numbers (Kotlin: msknumber())
  String _maskPhoneNumbers(String text) {
    final regex = RegExp(r'\b\d{5,12}\b');

    return text.replaceAllMapped(regex, (match) {
      final number = match.group(0)!;
      if (number.length <= 2) return number;

      final maskedPart = '*' * (number.length - 2);
      final lastTwoDigits = number.substring(number.length - 2);

      return maskedPart + lastTwoDigits;
    });
  }

  /// Send image message
  Future<void> _sendImage() async {
    try {
      // Show image source selection dialog
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      print('🔵 Uploading image...');

      // Upload to Firebase Storage
      final file = File(pickedFile.path);
      final storageRef = _storage
          .ref()
          .child('uploads')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      print('✅ Image uploaded: $imageUrl');

      // Create message with image - use local timestamp WITHOUT Z: "2025-12-18T13:22:21.523137"
      final timestamp = DateTime.now().toIso8601String().replaceAll('Z', '');

      print('📅 Image timestamp: $timestamp');

      final message = Message(
        message: null,
        senderId: _firebaseUserId,
        timestamp: timestamp,
        imageUrl: imageUrl,
      );

      // Send to Firebase
      await _database
          .child('chats')
          .child(_senderRoom)
          .child('messages')
          .push()
          .set(message.toJson());

      await _database
          .child('chats')
          .child(_receiverRoom)
          .child('messages')
          .push()
          .set(message.toJson());

      // Also send image to API server (Kotlin: sendimage())
      await _sendImageToApi(file);

      print('✅ Image message sent');

    } catch (e) {
      print('❌ Error sending image: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Send image to API server (Kotlin: sendimage())
  Future<void> _sendImageToApi(File imageFile) async {
    try {
      print('🔵 Sending image to API server...');

      final response = await _apiInterface.uploadChatImage(
        chatSessionId: _chatSessionId,
        senderId: _userId,
        imageFile: imageFile,
      );

      print('✅ Image sent to API: ${response.message}');
    } catch (e) {
      print('❌ Error sending image to API: $e');
      // Don't throw - image is already sent to Firebase
    }
  }

  /// Start countdown timer (Kotlin: countdown())
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _onTimerFinish();
        }
      });
    });
  }

  /// Timer finished (Kotlin: onFinish())
  void _onTimerFinish() {
    _timer?.cancel();

    // Update status to offline
    if (_firebaseUserId != null) {
      _chatService.updateUserStatus(_firebaseUserId!, 'offline');
    }

    // Navigate back or to chat history
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat session ended'),
          backgroundColor: Color(0xFFFF7213),
        ),
      );

      Navigator.pop(context);
    }
  }

  /// Format timer display
  String _formatTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Scroll to bottom
  void _scrollToBottom() {
    // Implement scroll to bottom logic if using ScrollController
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();

    // Update status to online when leaving chat
    if (_firebaseUserId != null) {
      _chatService.updateUserStatus(_firebaseUserId!, 'online');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://test.bhagyag.com${widget.profileImage}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.status,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Timer display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.senderId == _firebaseUserId;

                  return _buildMessageBubble(message, isMe);
                },
              ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Emoji button (placeholder)
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    color: Colors.grey,
                    onPressed: () {
                      // TODO: Implement emoji picker
                    },
                  ),

                  // Image button
                  IconButton(
                    icon: const Icon(Icons.image),
                    color: Colors.grey,
                    onPressed: _sendImage,
                  ),

                  // Message input
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Message',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF7213),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: _sendMessage,
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

  /// Build message bubble
  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFF7213) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: message.imageUrl != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.imageUrl!,
            fit: BoxFit.cover,
          ),
        )
            : Text(
          message.message ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Message model - Equivalent to Kotlin's Message class
class Message {
  final String? message;
  final String? senderId;
  final String timestamp;
  final String? imageUrl;

  Message({
    this.message,
    this.senderId,
    required this.timestamp,
    this.imageUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      senderId: json['senderId'],
      timestamp: json['timestamp'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
    };
  }
}