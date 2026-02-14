// lib/screens/firebase_chat_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/message.dart';
import '../models/chat_session_model.dart';
import '../models/send_chat_model.dart';

class FirebaseChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userFirebaseId;
  final String userProfileImage;
  final String astrologerId;

  const FirebaseChatScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userFirebaseId,
    required this.userProfileImage,
    required this.astrologerId,
  }) : super(key: key);

  @override
  State<FirebaseChatScreen> createState() => _FirebaseChatScreenState();
}

class _FirebaseChatScreenState extends State<FirebaseChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  DatabaseReference? _chatRef;
  StreamSubscription<DatabaseEvent>? _chatSub;
  List<Message> _messages = [];

  String? _senderRoom;
  String? _receiverRoom;
  int? _chatSessionId;
  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 minutes (300 seconds)

  bool _isUploadingImage = false;

  static const String BASE_URL = "https://test.bhagyag.com";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final senderUid = _auth.currentUser?.uid;
    if (senderUid == null) return;

    // Create room IDs (matching Kotlin logic)
    _senderRoom = '${widget.userFirebaseId}$senderUid';
    _receiverRoom = '$senderUid${widget.userFirebaseId}';

    debugPrint('✅ Sender Room: $_senderRoom');
    debugPrint('✅ Receiver Room: $_receiverRoom');

    // Update Firebase status to offline (astrologer is in chat)
    await _updateStatus(senderUid, 'offline');

    // Create chat session via API
    await _createChatSession();

    // Listen to Firebase messages
    _listenToMessages();

    // Start 5-minute countdown timer
    _startCountdown();
  }

  Future<void> _createChatSession() async {
    try {
      final url = Uri.parse('$BASE_URL/api/ChatSession');
      final requestBody = RequestChat(
        astrologerId: widget.astrologerId,
        chatSessionId: 0,
        userId: widget.userId,
      );

      debugPrint('📤 Creating chat session: ${requestBody.toJson()}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final chatModel = ChatModel.fromJson(jsonDecode(response.body));
        setState(() {
          _chatSessionId = chatModel.record.chatSessionId;
        });
        debugPrint('✅ Chat session created: $_chatSessionId');
      } else {
        debugPrint('❌ Chat session creation failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Create chat session error: $e');
    }
  }

  void _listenToMessages() {
    if (_senderRoom == null) return;

    _chatRef = FirebaseDatabase.instance.ref('chats/$_senderRoom/messages');

    _chatSub = _chatRef!.onValue.listen((event) {
      if (!event.snapshot.exists) {
        setState(() {
          _messages = [];
        });
        return;
      }

      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>?;
      if (messagesMap == null) {
        setState(() {
          _messages = [];
        });
        return;
      }

      final List<Message> loadedMessages = [];
      messagesMap.forEach((key, value) {
        if (value is Map) {
          loadedMessages.add(Message.fromJson(Map<dynamic, dynamic>.from(value)));
        }
      });

      // Sort by timestamp
      loadedMessages.sort((a, b) {
        try {
          final aTime = DateTime.parse(a.timestamp ?? '');
          final bTime = DateTime.parse(b.timestamp ?? '');
          return aTime.compareTo(bTime);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _messages = loadedMessages;
      });

      _scrollToBottom();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endChat();
      }
    });
  }

  void _endChat() {
    _countdownTimer?.cancel();

    if (_auth.currentUser?.uid != null) {
      _updateStatus(_auth.currentUser!.uid, 'online');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat session ended'),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _chatSessionId == null) return;

    final timestamp = DateTime.now().toIso8601String();
    final message = Message(
      message: messageText,
      senderId: _auth.currentUser?.uid,
      timestamp: timestamp,
      url: null,
    );

    // Send to Firebase
    await _sendToFirebase(message);

    // Send to API
    await _sendToAPI(messageText, timestamp);

    _messageController.clear();
  }

  Future<void> _sendToFirebase(Message message) async {
    if (_senderRoom == null || _receiverRoom == null) return;

    try {
      final senderRef = FirebaseDatabase.instance
          .ref('chats/$_senderRoom/messages')
          .push();
      final receiverRef = FirebaseDatabase.instance
          .ref('chats/$_receiverRoom/messages')
          .push();

      await senderRef.set(message.toJson());
      await receiverRef.set(message.toJson());

      debugPrint('✅ Message sent to Firebase');
    } catch (e) {
      debugPrint('❌ Firebase send error: $e');
    }
  }

  Future<void> _sendToAPI(String messageText, String timestamp) async {
    if (_chatSessionId == null) return;

    try {
      final url = Uri.parse('$BASE_URL/api/Chat');
      final requestBody = RequestSendChat(
        chatId: 0,
        chatSessionId: _chatSessionId!,
        senderId: widget.userId,
        messageText: messageText,
        msgType: 'string',
        sentOn: timestamp,
      );

      debugPrint('📤 Sending message to API: ${requestBody.toJson()}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Message sent to API');
      } else {
        debugPrint('❌ API send failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Send message API error: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      // Show image source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
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
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(File(image.path));

      // Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Send image message
      final timestamp = DateTime.now().toIso8601String();
      final message = Message(
        message: null,
        senderId: _auth.currentUser?.uid,
        timestamp: timestamp,
        url: downloadUrl,
      );

      await _sendToFirebase(message);

      setState(() {
        _isUploadingImage = false;
      });

      debugPrint('✅ Image sent: $downloadUrl');
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      debugPrint('❌ Image upload error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String uid, String status) async {
    final ref = FirebaseDatabase.instance.ref('user/$uid');
    await ref.update({
      'uid': uid,
      'status': status,
    });
    debugPrint('✅ Status updated: $status');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _maskName(String name) {
    if (name.length <= 2) return '*' * name.length;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Back button disabled during chat'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFD6E62),
          automaticallyImplyLeading: false, // Disable back button
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: widget.userProfileImage.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    '$BASE_URL/files/profile/${widget.userProfileImage}',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 20);
                    },
                  ),
                )
                    : const Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _maskName(widget.userName),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No messages yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageItem(_messages[index]);
                },
              ),
            ),
            if (_isUploadingImage)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Uploading image...'),
                  ],
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final isSentByMe = message.senderId == _auth.currentUser?.uid;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSentByMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: widget.userProfileImage.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    '$BASE_URL/files/profile/${widget.userProfileImage}',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 16);
                    },
                  ),
                )
                    : const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? const Color(0xFFFD6E62)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                    isSentByMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                    isSentByMe ? Radius.zero : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.url != null && message.url!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          // TODO: Open full screen image viewer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageViewer(
                                imageUrl: message.url!,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.url!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                        null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, size: 40, color: Colors.red),
                                    SizedBox(height: 8),
                                    Text('Failed to load image'),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else if (message.message != null &&
                        message.message!.isNotEmpty)
                      Text(
                        message.message!,
                        style: TextStyle(
                          fontSize: 15,
                          color: isSentByMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSentByMe ? Colors.white70 : Colors.black54,
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

  String _formatMessageTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xFFFD6E62)),
            onPressed: _isUploadingImage ? null : _pickAndSendImage,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Enter message',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFD6E62),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _chatSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();

    // Update status to online when leaving chat
    if (_auth.currentUser?.uid != null) {
      _updateStatus(_auth.currentUser!.uid, 'online');
    }

    super.dispose();
  }
}

// Full Screen Image Viewer
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 60, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}