import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/astrologer_model.dart';
import 'chat_astro/chat_service.dart'; // NEW: Import the chat service

/// ============================================================================
/// UPDATED: AstrologerDetailScreen with Kotlin functionality
/// ============================================================================
///
/// KEY CHANGES FROM ORIGINAL:
/// 1. Changed from StatelessWidget to StatefulWidget (for state management)
/// 2. Added Firebase real-time status monitoring
/// 3. Added wallet balance display
/// 4. Added chat session functionality
/// 5. Added loading states
/// 6. Integrated ChatService for API calls
/// ============================================================================
class AstrologerDetailScreen extends StatefulWidget {  // CHANGED: StatelessWidget → StatefulWidget
  final AstrologerModel astrologer;
  final String profileImageUrl;
  final String serviceType; // 'chat', 'voice', or 'video'

  const AstrologerDetailScreen({
    Key? key,
    required this.astrologer,
    required this.profileImageUrl,
    required this.serviceType,
  }) : super(key: key);

  @override
  State<AstrologerDetailScreen> createState() => _AstrologerDetailScreenState();
}

class _AstrologerDetailScreenState extends State<AstrologerDetailScreen> {
  // ========== NEW: Services ==========
  final ChatService _chatService = ChatService();  // NEW: Chat service instance

  // ========== NEW: State Variables ==========
  Stream<String>? _statusStream;  // FIXED: Changed from 'late' to nullable to prevent LateInitializationError
  String _userId = '';                // NEW: Current user ID
  double _walletBalance = 0.0;        // NEW: User wallet balance
  bool _isLoading = false;            // NEW: Loading state for button
  bool _isInitialized = false;        // NEW: Track if initialization is complete

  @override
  void initState() {
    super.initState();
    _initialize();  // NEW: Initialize when screen opens
  }

  /// ========== NEW FUNCTION: Initialize Screen ==========
  /// Equivalent to Kotlin's onCreate()
  /// - Loads user ID from SharedPreferences
  /// - Sets up Firebase status listener
  /// - Loads wallet balance
  /// - Requests chat session
  Future<void> _initialize() async {
    print('🔵 Initializing Astrologer Detail Screen');
    print('🔵 Astrologer: ${widget.astrologer.fullName}');
    print('🔵 Firebase ID: ${widget.astrologer.firebaseID}');

    // Get user ID from SharedPreferences (Kotlin equivalent: getSharedPreferences)
    final prefs = await SharedPreferences.getInstance();

    // DEBUG: Show all available keys
    print('🔍 Available SharedPreferences keys: ${prefs.getKeys()}');

    // FIXED: Use 'userId' instead of 'id'
    _userId = prefs.getString('userId') ?? '';  // Changed from 'id' to 'userId'

    print('🔍 User ID from SharedPreferences: "$_userId"');

    if (_userId.isEmpty) {
      print('❌ User ID is empty!');
      print('❌ All available keys: ${prefs.getKeys()}');

      // Check if any key contains 'id' or 'user' to help debug
      for (var key in prefs.getKeys()) {
        if (key.toLowerCase().contains('id') || key.toLowerCase().contains('user')) {
          print('🔍 Potential user key found: $key = ${prefs.get(key)}');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to continue. User ID not found.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context); // Go back
              },
            ),
          ),
        );

        // Navigate back after showing message
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
      return;
    }

    // Check for the special "not logged in" ID from Kotlin code
    if (_userId == '38cc683e-46bd-427e-a15a-08ddf834c0bc') {
      print('⚠️ User has default/guest ID - Not logged in');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to continue'),
            backgroundColor: Color(0xFFFF7213),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
      return;
    }

    print('✅ User ID loaded: $_userId');

    // Setup Firebase status stream (Kotlin equivalent: getUserStatus with ValueEventListener)
    _statusStream = _chatService.getUserStatus(widget.astrologer.firebaseID);

    // Load wallet balance (Kotlin equivalent: walletamount() function)
    await _loadWalletBalance();

    // Request initial chat session (Kotlin equivalent: postdata() function)
    await _requestChatSession();

    // Mark initialization as complete
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  /// ========== NEW FUNCTION: Load Wallet Balance ==========
  /// Equivalent to Kotlin's walletamount() function
  Future<void> _loadWalletBalance() async {
    try {
      _walletBalance = await _chatService.getWalletBalance(_userId);
      setState(() {});
      print('✅ Wallet balance loaded: ₹$_walletBalance');
    } catch (e) {
      print('❌ Error loading wallet balance: $e');
    }
  }

  /// ========== NEW FUNCTION: Request Chat Session ==========
  /// Equivalent to Kotlin's postdata() function
  Future<void> _requestChatSession() async {
    try {
      final chatModel = await _chatService.requestChatSession(
        userId: _userId,
        astrologerId: widget.astrologer.userId,  // FIXED: Using userId (GUID) instead of firebaseID
        chatSessionId: 0,
      );

      if (chatModel != null) {
        print('✅ Chat session created');
        print('✅ Session ID: ${chatModel.record.chatSessionId}');
      }
    } catch (e) {
      print('❌ Error requesting chat session: $e');
    }
  }

  /// ========== NEW FUNCTION: Start Chat ==========
  /// Equivalent to Kotlin's walletcheck() and getUserStatus() combined
  /// - Checks if user is logged in
  /// - Checks if astrologer is online
  /// - Verifies wallet balance
  /// - Starts chat session or shows error
  Future<void> _startChat(bool isOnline, String realtimeStatus) async {
    if (_isLoading) return;

    print('🔵 Start chat button clicked');
    print('🔵 Astrologer: ${widget.astrologer.fullName}');
    print('🔵 Status: $realtimeStatus');
    print('🔵 Is Online: $isOnline');

    // Check if user is logged in
    final isLoggedIn = await _chatService.checkUserLogin(context);
    if (!isLoggedIn) {
      return;
    }

    // Check if astrologer is online (Kotlin equivalent: getUserStatus check)
    if (!isOnline) {
      print('⚠️ Astrologer is offline');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Astrologer is Offline'),  // Kotlin: Toast.makeText("Astrologer is Offline")
            backgroundColor: Color(0xFF797676),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Check wallet and start chat (Kotlin equivalent: walletcheck() function)
      final success = await _chatService.checkWalletAndStartChat(
        context: context,
        userId: _userId,
        astrologerId: widget.astrologer.userId,  // FIXED: Using userId (GUID) instead of firebaseID
        firebaseId: widget.astrologer.firebaseID,  // Keep firebaseID for Firebase operations
        name: widget.astrologer.fullName,
        profileImage: widget.astrologer.profileImage,
        status: realtimeStatus,
        aboutMe: widget.astrologer.aboutMe,
        specialized: widget.astrologer.specializedIn,
        language: widget.astrologer.knownLanguages,
        rate: widget.astrologer.rating.toString(),
        chargesPerMinute: _getServiceCharge().toString(),
      );

      if (success) {
        print('✅ Chat started successfully');
        // Navigation to chat screen is handled inside checkWalletAndStartChat
      } else {
        print('⚠️ Chat start failed - Insufficient balance');
      }
    } catch (e) {
      print('❌ Error starting chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astrologer Details'),
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        // ========== NEW: Wallet Balance in AppBar ==========
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '₹${_walletBalance.toStringAsFixed(2)}',  // NEW: Shows wallet balance
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF5E6),
              const Color(0xFFFFE6D6),
            ],
          ),
        ),
        // ========== CHANGED: Added StreamBuilder for Real-Time Status ==========
        // Kotlin equivalent: addValueEventListener for Firebase status
        // FIXED: Check initialization and provide fallback stream to prevent LateInitializationError
        child: !_isInitialized
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7213)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        )
            : StreamBuilder<String>(
          stream: _statusStream ?? Stream.value('offline'),  // FIXED: Provide fallback stream
          initialData: widget.astrologer.status,
          builder: (context, snapshot) {
            // Get real-time status from Firebase
            final realtimeStatus = snapshot.data ?? 'offline';
            final isOnline = realtimeStatus.toLowerCase() == 'online';

            // Log status changes
            if (snapshot.hasData && snapshot.data != widget.astrologer.status) {
              print('🔄 Status changed for ${widget.astrologer.fullName}');
              print('   └─ From: ${widget.astrologer.status}');
              print('   └─ To: ${snapshot.data}');
            }

            return _buildContent(context, isOnline, realtimeStatus);
          },
        ),
      ),
    );
  }

  // ========== CHANGED: Build Content with Real-Time Status ==========
  Widget _buildContent(BuildContext context, bool isOnline, String realtimeStatus) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card - UPDATED to use real-time status
            _buildProfileCard(isOnline),
            const SizedBox(height: 20),

            // Details Section
            _buildDetailCard(
              title: 'Specialized In',
              icon: Icons.auto_awesome,
              content: widget.astrologer.specializedIn,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              title: 'Languages Known',
              icon: Icons.language,
              content: widget.astrologer.knownLanguages,
            ),
            const SizedBox(height: 12),
            _buildDetailCard(
              title: 'About Me',
              icon: Icons.info_outline,
              content: widget.astrologer.aboutMe.isNotEmpty
                  ? widget.astrologer.aboutMe
                  : 'No description available',
            ),
            const SizedBox(height: 20),

            // Charges Section
            const Text(
              'Charges',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x70FAFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildChargeRow(
                _getServiceLabel(),
                _getServiceIcon(),
                _getServiceCharge(),
              ),
            ),
            const SizedBox(height: 30),

            // Action Button - UPDATED with real functionality
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                context,
                _getServiceLabel(),
                _getServiceIcon(),
                _getServiceColor(),
                isOnline,        // NEW: Uses real-time status
                realtimeStatus,  // NEW: Passes status to function
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========== UPDATED: Profile Card with Real-Time Status ==========
  Widget _buildProfileCard(bool isOnline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0x70FAFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Profile Image with Status
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF5722),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: widget.astrologer.profileImage.isNotEmpty
                      ? Image.network(
                    '${widget.profileImageUrl}${widget.astrologer.profileImage}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person,
                              size: 50, color: Colors.grey),
                        ),
                  )
                      : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person,
                        size: 50, color: Colors.grey),
                  ),
                ),
              ),
              // UPDATED: Online status indicator uses real-time data
              if (isOnline)
                Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name with Verified Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.astrologer.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.verified, size: 24, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 8),

          // ========== NEW: Status Badge ==========
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOnline ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                5,
                    (index) => Icon(
                  index < widget.astrologer.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 18,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.astrologer.rating.toStringAsFixed(1)})',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Experience
          Text(
            'Experience: ${widget.astrologer.experience}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF797676)),
          ),
        ],
      ),
    );
  }

  String _getServiceLabel() {
    switch (widget.serviceType) {
      case 'chat':
        return 'Chat';
      case 'voice':
        return 'Voice Call';
      case 'video':
        return 'Video Call';
      default:
        return 'Chat';
    }
  }

  IconData _getServiceIcon() {
    switch (widget.serviceType) {
      case 'chat':
        return Icons.chat_bubble;
      case 'voice':
        return Icons.phone;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.chat_bubble;
    }
  }

  int _getServiceCharge() {
    switch (widget.serviceType) {
      case 'chat':
        return widget.astrologer.chargesPerMinutes;
      case 'voice':
        return widget.astrologer.voiceCallPerMinutes;
      case 'video':
        return widget.astrologer.videoCallPerMinuters;
      default:
        return widget.astrologer.chargesPerMinutes;
    }
  }

  Color _getServiceColor() {
    switch (widget.serviceType) {
      case 'chat':
        return const Color(0xFF00C853);
      case 'voice':
        return const Color(0xFF2196F3);
      case 'video':
        return const Color(0xFFFF7213);
      default:
        return const Color(0xFF00C853);
    }
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x70FAFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFF7213)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF797676)),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeRow(String service, IconData icon, int charge) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFFF7213)),
            const SizedBox(width: 12),
            Text(
              service,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.currency_rupee, size: 16, color: Colors.black),
            Text(
              '$charge/min',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== UPDATED: Action Button with Real Functionality ==========
  // Kotlin equivalent: Chat button with getUserStatus and walletcheck
  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      bool isEnabled,
      String realtimeStatus,
      ) {
    return ElevatedButton(
      // CHANGED: Now calls _startChat instead of showing "coming soon"
      onPressed: _isLoading
          ? null
          : () => _startChat(isEnabled, realtimeStatus),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : const Color(0xFF797676),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        disabledBackgroundColor: const Color(0xFF797676),
      ),
      // NEW: Shows loading spinner when processing
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}