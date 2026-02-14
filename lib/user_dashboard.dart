import 'package:bhagyag/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'userprofile.dart';
import 'about_us_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';
import 'voice_call_screen.dart';
import 'video_call_screen.dart';
import 'astrologer_detail_screen.dart';
import 'models/astrologer_model.dart';
import 'transaction_history_screen.dart';
import 'wallet_history_screen.dart';
import 'language_selection_screen.dart';
import 'ai_astrology_chat_integrated.dart';
import 'ai_astrology_journal_integrated.dart';
import 'language_provider.dart';
import 'shop_screen.dart';

// ==================== DATA MODELS ====================
// [Keep all existing models unchanged]

class WalletBalanceModel {
  final int walletId;
  final String userId;
  final double balance;
  final String lastUpdated;
  final String chatFree;

  WalletBalanceModel({
    required this.walletId,
    required this.userId,
    required this.balance,
    required this.lastUpdated,
    required this.chatFree,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      walletId: json['walletId'] ?? 0,
      userId: json['userId'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      lastUpdated: json['lastUpdated'] ?? '',
      chatFree: json['chatFree'] ?? '',
    );
  }
}

class SupportRequest {
  final String userId;
  final String reason;
  final String requestType;

  SupportRequest({
    required this.userId,
    required this.reason,
    required this.requestType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reason': reason,
      'requestType': requestType,
    };
  }
}

class YoutubeVideo {
  final int id;
  final String youtubeUrl;

  YoutubeVideo({required this.id, required this.youtubeUrl});

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    return YoutubeVideo(
      id: json['id'] ?? 0,
      youtubeUrl: json['youtubeUrl'] ?? '',
    );
  }
}

class Astrologer {
  final int chargesPerMinutes;
  final String fullName;
  final String knownLanguages;
  final String profileImage;
  final double rating;
  final String specializedIn;
  final int totalChatMinutes;
  final String userId;
  final String workingSince;
  final String firebaseID;
  final String chatStatus;
  String status;
  final String aboutMe;
  final String experience;
  final String voiceCallPerMinutes;
  final String videoCallPerMinutes;

  Astrologer({
    required this.chargesPerMinutes,
    required this.fullName,
    required this.knownLanguages,
    required this.profileImage,
    required this.rating,
    required this.specializedIn,
    required this.totalChatMinutes,
    required this.userId,
    required this.workingSince,
    required this.firebaseID,
    required this.chatStatus,
    required this.status,
    required this.aboutMe,
    required this.experience,
    required this.voiceCallPerMinutes,
    required this.videoCallPerMinutes,
  });

  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      chargesPerMinutes: json['chargesPerMinutes'] ?? 0,
      fullName: json['fullName'] ?? '',
      knownLanguages: json['knownLanguages'] ?? '',
      profileImage: json['profileImage'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      specializedIn: json['specializedIn'] ?? '',
      totalChatMinutes: json['totalChatMinutes'] ?? 0,
      userId: json['userId'] ?? '',
      workingSince: json['workingSince'] ?? '',
      firebaseID: json['firebaseID'] ?? '',
      chatStatus: json['chatStatus'] ?? 'offline',
      status: json['status'] ?? 'offline',
      aboutMe: json['aboutMe'] ?? '',
      experience: json['experience'] ?? '',
      voiceCallPerMinutes: json['voiceCallPerMinutes']?.toString() ?? '',
      videoCallPerMinutes: json['videoCallPerMinutes']?.toString() ?? '',
    );
  }

  AstrologerModel toAstrologerModel() {
    return AstrologerModel(
      chargesPerMinutes: chargesPerMinutes,
      fullName: fullName,
      knownLanguages: knownLanguages,
      profileImage: profileImage,
      rating: rating,
      specializedIn: specializedIn,
      totalChatMinutes: totalChatMinutes,
      userId: userId,
      workingSince: workingSince,
      firebaseID: firebaseID,
      chatStatus: chatStatus,
      status: status,
      aboutMe: aboutMe,
      experience: experience,
      voiceCallPerMinutes: int.tryParse(voiceCallPerMinutes) ?? 0,
      videoCallPerMinuters: int.tryParse(videoCallPerMinutes) ?? 0,
    );
  }
}

class BannerItem {
  final String connectionUrl;
  final String heading;
  final int id;
  final String bannerImage;

  BannerItem({
    required this.connectionUrl,
    required this.heading,
    required this.id,
    required this.bannerImage,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      connectionUrl: json['connectionURl'] ?? '',
      heading: json['heading'] ?? '',
      id: json['id'] ?? 0,
      bannerImage: json['bannerImage'] ?? '',
    );
  }
}

// ==================== API SERVICE ====================
// [Keep all API services unchanged]

class ApiService {
  static const String baseUrl = 'https://test.bhagyag.com';
  static const String bannerBaseUrl = 'https://test.bhagyag.com/files/banners/';
  static const String profileImageUrl = 'https://test.bhagyag.com/files/profile/';

  static Future<WalletBalanceModel?> getWalletBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Wallet/$userId'),
      );

      print('Wallet API Response: ${response.statusCode}');
      print('Wallet Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return WalletBalanceModel.fromJson(json.decode(response.body));
      } else {
        print('Failed to load wallet balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading wallet balance: $e');
      return null;
    }
  }

  static Future<bool> submitSupportRequest(SupportRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/CustomerSupport/submit-request'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      print('Support Request Response: ${response.statusCode}');
      print('Support Response Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error submitting support request: $e');
      return false;
    }
  }

  static Future<List<YoutubeVideo>> getYoutubeVideos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/YoutubeLink'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => YoutubeVideo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading videos: $e');
      return [];
    }
  }

  static Future<List<Astrologer>> getAstrologers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/User/AstrologerList'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Astrologer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load astrologers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading astrologers: $e');
      return [];
    }
  }

  static Future<List<BannerItem>> getBanners() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/Banner'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => BannerItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading banners: $e');
      return [];
    }
  }
}

// ==================== FIREBASE SERVICE ====================
// [Keep Firebase service unchanged]

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  static Future<bool> initializeAndSignIn(String userId) async {
    try {
      final email = '$userId@gmail.com';
      final password = userId;

      print('🔥 Attempting Firebase sign in...');
      print('Email: $email');

      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase sign in successful');
      } catch (e) {
        print('⚠️ Sign in failed, creating new account...');
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Firebase account created');
      }

      await updateUserStatus('online');

      return true;
    } catch (e) {
      print('❌ Firebase initialization error: $e');
      return false;
    }
  }

  static Future<void> updateUserStatus(String status) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _database.child('user').child(user.uid).child('status').set(status);
        print('✅ Status updated to: $status');

        await _database
            .child('user')
            .child(user.uid)
            .child('status')
            .onDisconnect()
            .set('offline');
      }
    } catch (e) {
      print('❌ Error updating status: $e');
    }
  }

  static Stream<String> listenToAstrologerStatus(String firebaseId) {
    print('🎯 Creating stream listener for: $firebaseId');

    return _database
        .child('user')
        .child(firebaseId)
        .child('status')
        .onValue
        .map((event) {
      final status = event.snapshot.value?.toString() ?? 'offline';
      final timestamp = DateTime.now().toString();

      print('🔔 [$timestamp] Status event for $firebaseId');
      print('   └─ Value: ${event.snapshot.value}');
      print('   └─ Parsed status: $status');
      print('   └─ Snapshot exists: ${event.snapshot.exists}');

      return status;
    }).handleError((error) {
      print('❌ Stream error for $firebaseId: $error');
      return 'offline';
    });
  }

  static String? getCurrentUserFirebaseId() {
    return _auth.currentUser?.uid;
  }

  static Future<void> signOut() async {
    try {
      await updateUserStatus('offline');
      await _auth.signOut();
      print('✅ Firebase sign out successful');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }
}

// ==================== 🔥 RESPONSIVE ASTROLOGER CARD ====================

class AstrologerCardWithRealTimeStatus extends StatefulWidget {
  final Astrologer astrologer;
  final String chatFreeStatus;
  final VoidCallback onTap;

  const AstrologerCardWithRealTimeStatus({
    Key? key,
    required this.astrologer,
    required this.chatFreeStatus,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AstrologerCardWithRealTimeStatus> createState() =>
      _AstrologerCardWithRealTimeStatusState();
}

class _AstrologerCardWithRealTimeStatusState
    extends State<AstrologerCardWithRealTimeStatus> {
  late Stream<String> _statusStream;

  @override
  void initState() {
    super.initState();
    _statusStream = FirebaseService.listenToAstrologerStatus(
      widget.astrologer.firebaseID,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 Responsive sizing
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isWeb && screenWidth > 600 ? 160.0 : 145.0;
    final cardHeight = isWeb && screenWidth > 600 ? 240.0 : 220.0;

    return StreamBuilder<String>(
      stream: _statusStream,
      initialData: widget.astrologer.status,
      builder: (context, snapshot) {
        final realtimeStatus = snapshot.data ?? 'offline';
        final isOnline = realtimeStatus.toLowerCase() == 'online';
        final isFreeChat = widget.chatFreeStatus.toLowerCase() == 'false';

        if (snapshot.hasData && snapshot.data != widget.astrologer.status) {
          print('🔄 Status changed for ${widget.astrologer.fullName}');
          print('   └─ From: ${widget.astrologer.status}');
          print('   └─ To: ${snapshot.data}');
        }

        Color buttonColor;
        String buttonText;
        bool buttonEnabled;
        bool showStrikethrough = false;

        if (isOnline && isFreeChat) {
          buttonColor = const Color(0xFF00C853);
          buttonText = 'Chat Free';
          buttonEnabled = true;
          showStrikethrough = true;
        } else if (isOnline && !isFreeChat) {
          buttonColor = const Color(0xFF00C853);
          buttonText = 'Chat';
          buttonEnabled = true;
          showStrikethrough = false;
        } else {
          buttonColor = const Color(0xFF797676);
          buttonText = 'Chat';
          buttonEnabled = false;
          showStrikethrough = false;
        }

        return _buildCardUI(
          isOnline: isOnline,
          buttonColor: buttonColor,
          buttonText: buttonText,
          buttonEnabled: buttonEnabled,
          showStrikethrough: showStrikethrough,
          realtimeStatus: realtimeStatus,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
        );
      },
    );
  }

  Widget _buildCardUI({
    required bool isOnline,
    required Color buttonColor,
    required String buttonText,
    required bool buttonEnabled,
    required bool showStrikethrough,
    required String realtimeStatus,
    required double cardWidth,
    required double cardHeight,
  }) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final avatarSize = isWeb && screenWidth > 600 ? 80.0 : 72.0;
    final nameSize = isWeb && screenWidth > 600 ? 17.0 : 16.0;
    final priceSize = isWeb && screenWidth > 600 ? 15.0 : 14.0;
    final buttonTextSize = isWeb && screenWidth > 600 ? 16.0 : 15.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isWeb ? 16 : 12,
          top: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0x70FAFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: isWeb ? 6 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF5722),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.astrologer.profileImage.isNotEmpty
                        ? Image.network(
                      '${ApiService.profileImageUrl}${widget.astrologer.profileImage}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF7213),
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFF5E6),
                          child: Icon(
                            Icons.person,
                            size: avatarSize * 0.5,
                            color: const Color(0xFFFF7213),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: const Color(0xFFFFF5E6),
                      child: Icon(
                        Icons.person,
                        size: avatarSize * 0.5,
                        color: const Color(0xFFFF7213),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.astrologer.fullName,
                style: TextStyle(
                  fontSize: nameSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '₹${widget.astrologer.chargesPerMinutes}/min',
                style: TextStyle(
                  fontSize: priceSize,
                  color: const Color(0xFF727272),
                  decoration: showStrikethrough
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationThickness: 2,
                  decorationColor: const Color(0xFF727272),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: buttonEnabled
                  ? () {
                print('🔵 Chat button clicked');
                print('🔵 Astrologer: ${widget.astrologer.fullName}');
                print('🔵 Real-time Status: $realtimeStatus');
                widget.onTap();
              }
                  : () {
                print('⚠️ Astrologer ${widget.astrologer.fullName} is offline');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Astrologer is currently offline'),
                    backgroundColor: Color(0xFFFF7213),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                height: isWeb && screenWidth > 600 ? 34 : 30,
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb && screenWidth > 600 ? 18 : 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    color: const Color(0xFFF2F4F2),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
class _BannerImageItem extends StatefulWidget {
  final String imageUrl;
  final String heading;
  final String connectionUrl;
  final VoidCallback onTap;

  const _BannerImageItem({
    Key? key,
    required this.imageUrl,
    required this.heading,
    required this.connectionUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_BannerImageItem> createState() => _BannerImageItemState();
}

class _BannerImageItemState extends State<_BannerImageItem> {
  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Same responsive fallback height logic for loading/error states
    double fallbackHeight;
    if (isWeb && screenWidth > 900) {
      fallbackHeight = (screenWidth * 0.30).clamp(220.0, 350.0);
    } else if (isWeb && screenWidth > 600) {
      fallbackHeight = (screenWidth * 0.35).clamp(200.0, 300.0);
    } else {
      fallbackHeight = (screenHeight * 0.22).clamp(160.0, 240.0);
    }

    return MouseRegion(
      cursor: widget.connectionUrl.isNotEmpty
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.connectionUrl.isNotEmpty ? widget.onTap : null,
        child: widget.imageUrl.isNotEmpty
            ? Image.network(
          widget.imageUrl,
          width: double.infinity,
          fit: BoxFit.cover, // ✅ cover fills full width AND height
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: fallbackHeight,
              color: Colors.orange.shade50,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF7213),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: fallbackHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade300,
                    Colors.orange.shade600,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  widget.heading,
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        )
            : Container(
          height: fallbackHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade300,
                Colors.orange.shade600,
              ],
            ),
          ),
          child: Center(
            child: Text(
              widget.heading,
              style: TextStyle(
                fontSize: isWeb ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN DASHBOARD ====================
// [Continue in next part due to length...]

class UserDashboard extends StatefulWidget {
  final String userName;
  final String walletAmount;

  const UserDashboard({
    Key? key,
    required this.userName,
    this.walletAmount = '₹0',
  }) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // User Data
  String _phoneNumber = '';
  String _userId = '';
  String _walletAmount = '₹0.00';
  bool _isLoadingWallet = false;
  String _chatFreeStatus = 'true';

  // API Data
  List<Astrologer> _astrologers = [];
  List<YoutubeVideo> _youtubeVideos = [];
  List<BannerItem> _banners = [];

  // Loading States
  bool _isLoadingAstrologers = true;
  bool _isLoadingVideos = true;
  bool _isLoadingBanners = true;

  // Banner Auto-Scroll
  late PageController _bannerPageController;
  Timer? _bannerTimer;
  int _currentBannerPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bannerPageController = PageController(initialPage: 0);
    _loadUserData();
    _loadAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    FirebaseService.signOut();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('🔄 App resumed - setting status to online');
        FirebaseService.updateUserStatus('online');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('🔄 App paused/inactive - setting status to offline');
        FirebaseService.updateUserStatus('offline');
        break;
      case AppLifecycleState.detached:
        print('🔄 App detached - signing out');
        FirebaseService.signOut();
        break;
      default:
        break;
    }
  }

  void _startBannerAutoScroll() {
    _bannerTimer?.cancel();
    if (_banners.isNotEmpty) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_bannerPageController.hasClients) {
          _currentBannerPage = (_currentBannerPage + 1) % _banners.length;
          _bannerPageController.animateToPage(
            _currentBannerPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneNumber = prefs.getString('phoneNo') ?? '+91 1234567890';
      _userId = prefs.getString('userId') ?? '';
    });

    if (_userId.isNotEmpty) {
      await FirebaseService.initializeAndSignIn(_userId);
      await _loadWalletBalance();
    }
  }

  Future<void> _loadWalletBalance() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoadingWallet = true);

    try {
      final walletData = await ApiService.getWalletBalance(_userId);

      if (walletData != null) {
        setState(() {
          _walletAmount = '₹${walletData.balance.toStringAsFixed(2)}';
          _chatFreeStatus = walletData.chatFree;
          _isLoadingWallet = false;
        });
        print('✅ Wallet balance loaded: $_walletAmount');
        print('✅ Chat free status: $_chatFreeStatus');
      } else {
        setState(() {
          _walletAmount = widget.walletAmount;
          _isLoadingWallet = false;
        });
        print('⚠️ Wallet data is null, using fallback');
      }
    } catch (e) {
      print('❌ Error loading wallet: $e');
      setState(() {
        _walletAmount = widget.walletAmount;
        _isLoadingWallet = false;
      });
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadAstrologers(),
      _loadYoutubeVideos(),
      _loadBanners(),
    ]);
  }

  Future<void> _loadAstrologers() async {
    setState(() => _isLoadingAstrologers = true);

    try {
      final astrologers = await ApiService.getAstrologers();

      setState(() {
        _astrologers = astrologers;
        _isLoadingAstrologers = false;
      });

      print('✅ Loaded ${astrologers.length} astrologers');
    } catch (e) {
      print('❌ Error loading astrologers: $e');
      setState(() => _isLoadingAstrologers = false);
    }
  }

  Future<void> _loadYoutubeVideos() async {
    setState(() => _isLoadingVideos = true);
    try {
      final videos = await ApiService.getYoutubeVideos();
      final validVideos = videos.where((video) =>
      video.youtubeUrl.isNotEmpty &&
          (video.youtubeUrl.contains('youtube.com') || video.youtubeUrl.contains('youtu.be'))
      ).toList();

      setState(() {
        _youtubeVideos = validVideos;
        _isLoadingVideos = false;
      });
      print('✅ Loaded ${validVideos.length} valid videos out of ${videos.length}');
    } catch (e) {
      print('❌ Error loading videos: $e');
      setState(() => _isLoadingVideos = false);
    }
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoadingBanners = true);
    try {
      final banners = await ApiService.getBanners();
      setState(() {
        _banners = banners;
        _isLoadingBanners = false;
      });
      print('✅ Loaded ${banners.length} banners');
      _startBannerAutoScroll();
    } catch (e) {
      print('❌ Error loading banners: $e');
      setState(() => _isLoadingBanners = false);
    }
  }

  // [Keep all dialog methods unchanged - they work fine]
  // _showSupportDialog, _showWalletDialog, _showLogoutDialog, etc.

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSupportOption(
              'I am experiencing a technical problem',
              Icons.bug_report,
                  () => _showReasonInputDialog('support', 'Technical Problem'),
            ),
            const SizedBox(height: 12),
            _buildSupportOption(
              'Refund wallet balance',
              Icons.money_off,
                  () => _showReasonInputDialog('refund', 'Refund Request'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption(String title, IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF7213).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFF7213)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showReasonInputDialog(String requestType, String title) {
    final reasonController = TextEditingController();
    int charCount = 0;
    const maxChars = 250;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Reason for: $title',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                maxLength: maxChars,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Please describe your issue...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
                onChanged: (text) {
                  setDialogState(() {
                    charCount = text.length;
                  });
                  if (text.length == maxChars) {
                    _showSnackBar('Maximum characters reached (250)');
                  }
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$charCount/$maxChars',
                  style: TextStyle(
                    fontSize: 12,
                    color: charCount == maxChars ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Request cancelled');
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  _showSnackBar('Reason cannot be empty. Please provide details.');
                  return;
                }

                Navigator.pop(context);
                await _submitSupportRequest(requestType, reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7213),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSupportRequest(String requestType, String reason) async {
    if (_userId.isEmpty) {
      _showSnackBar('User ID not found. Please log in again.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF7213)),
      ),
    );

    final request = SupportRequest(
      userId: _userId,
      reason: reason,
      requestType: requestType,
    );

    final success = await ApiService.submitSupportRequest(request);

    Navigator.pop(context);

    if (success) {
      final message = requestType == 'support'
          ? 'Support request submitted successfully!'
          : 'Refund request submitted successfully!';
      _showSuccessSnackBar(message);
    } else {
      _showSnackBar('Failed to submit request. Please try again.');
    }
  }

  void _showWalletDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('My Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoadingWallet
                ? const CircularProgressIndicator(color: Color(0xFFFF7213))
                : Text(
              _walletAmount,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF7213),
              ),
            ),
            const SizedBox(height: 16),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnackBar('Add money feature coming soon!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7213),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Add Money', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _loadWalletBalance();
                  _showSnackBar('Wallet refreshed!');
                },
                child: const Text('Refresh Balance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Do you want to logout?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _handleLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF7213)),
      ),
    );

    try {
      await FirebaseService.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('✅ SharedPreferences cleared');
      print('✅ Firebase signed out');

      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Logged out successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }

      print('❌ Error during logout: $e');
      _showSnackBar('Logout failed. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF7213),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Could not open the link');
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showSnackBar('Error opening link');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5E6),
              Color(0xFFFFE6D6),
            ],
          ),
        ),
        child: Column(
          children: [
            // ✅ AppBar is NOT wrapped in Center/ConstrainedBox
            _buildAppBar(),
            // ✅ Only the content below is constrained
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 1200 : size.width,
                  ),
                  child: _getSelectedPage(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAppBar() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      // ✅ Remove any width constraints here - let it fill parent
      width: double.infinity, // This ensures it matches parent width
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 0, // Remove left padding from container
        right: 0, // Remove right padding from container
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF7213),
            Color(0xFFFF8C42),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // ✅ Wrap Row in Center with ConstrainedBox to limit content width
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 1200 : screenWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 24 : 16,
            ),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: isWeb && screenWidth > 600 ? 28 : 24,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                const Spacer(),
                Text(
                  _walletAmount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb && screenWidth > 600 ? 17 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: isWeb && screenWidth > 600 ? 26 : 24,
                    ),
                    onPressed: () => _showWalletDialog(),
                  ),
                ),
                SizedBox(width: isWeb ? 12 : 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: isWeb && screenWidth > 600 ? 26 : 24,
                    ),
                    onPressed: () => _showSupportDialog(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF7213).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            _buildDrawerItem(Icons.home, 'Home', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.person, 'My Profile', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userName: widget.userName,
                    phoneNumber: _phoneNumber,
                    email: 'user@example.com',
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.shopping_bag, 'Shop Products', () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1;
              });
            }),
            _buildDrawerItem(Icons.auto_awesome, 'AI Astrology Chat', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIAstrologyChatScreen(
                    userId: _userId,
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.book, 'Astro Journal', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIAstrologyJournalScreen(
                    userId: _userId,
                  ),
                ),
              );
            }),
            _buildDrawerItem(Icons.account_balance_wallet, 'My Wallet', () {
              Navigator.pop(context);
              _showWalletDialog();
            }),
            _buildDrawerItem(Icons.wallet_outlined, 'Wallet History', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WalletHistoryScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.history, 'Order History', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.history_sharp, 'Transaction History', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.support_agent, 'Support', () {
              Navigator.pop(context);
              _showSupportDialog();
            }),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            }),
            const Divider(),
            _buildDrawerItem(Icons.share, 'Share App', () {
              Navigator.pop(context);
            }),
            _buildDrawerItem(Icons.info, 'About Us', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutUsScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.logout, 'Logout', () {
              Navigator.pop(context);
              _showLogoutDialog();
            }, isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final isWeb = kIsWeb;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: isWeb ? 20 : 16,
        right: isWeb ? 20 : 16,
        bottom: isWeb ? 20 : 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF7213),
            Color(0xFFFF8C42),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isWeb ? 45 : 40,
            backgroundColor: Colors.white,
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: isWeb ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF7213),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.userName,
            style: TextStyle(
              color: Colors.white,
              fontSize: isWeb ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _phoneNumber,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isWeb ? 15 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    final isWeb = kIsWeb;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : const Color(0xFFFF7213),
          size: isWeb ? 26 : 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isWeb ? 17 : 16,
            color: isLogout ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isWeb = kIsWeb;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: isWeb ? 70 : 60,
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.shopping_bag, 'Shop', 1),
            const SizedBox(width: 60),
            _buildNavItem(Icons.chat_bubble, 'Chat', 2),
            _buildNavItem(Icons.phone, 'Call', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFFF7213) : Colors.grey,
                size: isWeb && screenWidth > 600 ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: isWeb && screenWidth > 600 ? 13 : 11,
                  color: isSelected ? const Color(0xFFFF7213) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
        backgroundColor: Colors.white,
        elevation: 4,
        child: Icon(
          Icons.video_call,
          color: const Color(0xFFFF7213),
          size: isWeb && screenWidth > 600 ? 36 : 32,
        ),
      ),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const ShopScreen();
      case 2:
        return _buildChatPage();
      case 3:
        return _buildCallPage();
      case 4:
        return const VideoCallScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadAllData();
        await _loadWalletBalance();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 1000 : screenWidth,
            ),
            child: Padding(
              padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isWeb ? 24 : 16),
                  _buildBannersSlider(),
                  SizedBox(height: isWeb ? 40 : 32),
                  _buildAstrologersSection(),
                  SizedBox(height: isWeb ? 40 : 32),
                  _buildYoutubeSection(),
                  SizedBox(height: isWeb ? 100 : 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBannersSlider() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Loading state
    if (_isLoadingBanners) {
      return Container(
        height: isWeb ? 240 : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.orange.shade400],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // ✅ Empty state
    if (_banners.isEmpty) {
      return Container(
        height: isWeb ? 240 : 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade600],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome,
                    size: isWeb ? 70 : 60, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  'First Chat Free!',
                  style: TextStyle(
                    fontSize: isWeb ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get instant answers from expert astrologers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWeb ? 16 : 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ Banner height calculation for BOTH mobile and web
    double bannerHeight;
    if (isWeb && screenWidth > 900) {
      // Large web screen
      bannerHeight = screenWidth * 0.30; // ~30% of screen width
      bannerHeight = bannerHeight.clamp(250.0, 450.0);
    } else if (isWeb && screenWidth > 600) {
      // Medium web / tablet
      bannerHeight = screenWidth * 0.35;
      bannerHeight = bannerHeight.clamp(200.0, 300.0);
    } else {
      // ✅ Mobile — use screenHeight based so it's not too small or too large
      bannerHeight = screenHeight * 0.22; // 22% of screen height
      bannerHeight = bannerHeight.clamp(160.0, 240.0);
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            height: bannerHeight,
            child: PageView.builder(
              controller: _bannerPageController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() => _currentBannerPage = index);
              },
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return _BannerImageItem(
                  imageUrl: banner.bannerImage.isNotEmpty
                      ? '${ApiService.bannerBaseUrl}${banner.bannerImage}'
                      : '',
                  heading: banner.heading,
                  connectionUrl: banner.connectionUrl,
                  onTap: () => _launchURL(banner.connectionUrl),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ✅ Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? const Color(0xFFFF7213)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAstrologersSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Astrologers',
              style: TextStyle(
                fontSize: isWeb && screenWidth > 600 ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                        color: const Color(0xFFFF7213),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFFF7213),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingAstrologers
            ? SizedBox(
          height: isWeb ? 240 : 200,
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF7213),
            ),
          ),
        )
            : _astrologers.isEmpty
            ? Container(
          height: isWeb ? 240 : 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: isWeb ? 70 : 60,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'No astrologers available',
                style: TextStyle(
                  fontSize: isWeb ? 18 : 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
            : SizedBox(
          height: isWeb && screenWidth > 600 ? 260 : 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: isWeb ? 8 : 4),
            itemCount: _astrologers.length > 10 ? 10 : _astrologers.length,
            itemBuilder: (context, index) {
              final astrologer = _astrologers[index];

              return AstrologerCardWithRealTimeStatus(
                key: ValueKey(astrologer.firebaseID),
                astrologer: astrologer,
                chatFreeStatus: _chatFreeStatus,
                onTap: () {
                  try {
                    final astrologerModel = astrologer.toAstrologerModel();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AstrologerDetailScreen(
                          astrologer: astrologerModel,
                          profileImageUrl: ApiService.profileImageUrl,
                          serviceType: 'chat',
                        ),
                      ),
                    );
                  } catch (e) {
                    print('❌ Error navigating to detail: $e');
                    _showSnackBar('Error: $e');
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubeSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoadingVideos) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: CircularProgressIndicator(
            color: const Color(0xFFFF7213),
            strokeWidth: isWeb ? 4 : 3,
          ),
        ),
      );
    }

    if (_youtubeVideos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: isWeb ? 70 : 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos available',
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Videos',
          style: TextStyle(
            fontSize: isWeb && screenWidth > 600 ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _youtubeVideos.length,
          itemBuilder: (context, index) {
            return _buildYoutubeCard(_youtubeVideos[index]);
          },
        ),
      ],
    );
  }

  Widget _buildYoutubeCard(YoutubeVideo video) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final videoId = _extractVideoId(video.youtubeUrl);
    final videoHeight = isWeb && screenWidth > 600 ? 240.0 : 200.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              videoId != null
                  ? Image.network(
                'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                width: double.infinity,
                height: videoHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: videoHeight,
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.error_outline,
                      size: isWeb ? 70 : 60,
                      color: Colors.grey,
                    ),
                  );
                },
              )
                  : Container(
                width: double.infinity,
                height: videoHeight,
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.videocam_off,
                  size: isWeb ? 70 : 60,
                  color: Colors.grey,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _launchURL(video.youtubeUrl),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      child: Center(
                        child: Icon(
                          Icons.play_circle_filled,
                          size: isWeb && screenWidth > 600 ? 90 : 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _extractVideoId(String url) {
    try {
      if (url.contains('youtube.com/watch')) {
        final uri = Uri.parse(url);
        return uri.queryParameters['v'];
      } else if (url.contains('youtu.be/')) {
        return url.split('youtu.be/')[1].split('?')[0];
      } else if (url.contains('youtube.com/embed/')) {
        return url.split('youtube.com/embed/')[1].split('?')[0];
      }
    } catch (e) {
      print('Error extracting video ID: $e');
    }
    return null;
  }

  Widget _buildChatPage() {
    return const ChatScreen();
  }

  Widget _buildCallPage() {
    return const VoiceCallScreen();
  }

  Widget _buildProfilePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(
            userName: widget.userName,
            phoneNumber: _phoneNumber,
            email: 'user@example.com',
          ),
        ),
      ).then((_) {
        setState(() {
          _selectedIndex = 0;
        });
      });
    });

    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFFF7213),
      ),
    );
  }
}