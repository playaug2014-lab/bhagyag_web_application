import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'astrologer_dashboard_screen.dart';
import 'astrologer_registration_step.dart';

/// Enhanced Astrologer Login Screen with API Integration
/// Features:
/// - Real API integration with backend
/// - Animated gradient background with particle effects
/// - Glassmorphism design
/// - User type verification (ASTROLOGER vs USER)
/// - SharedPreferences for session management
/// - Multi-language support
/// - Responsive design for web and mobile
class EnhancedAstrologerLoginScreen extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;

  const EnhancedAstrologerLoginScreen({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
  }) : super(key: key);

  @override
  State<EnhancedAstrologerLoginScreen> createState() =>
      _EnhancedAstrologerLoginScreenState();
}

class _EnhancedAstrologerLoginScreenState
    extends State<EnhancedAstrologerLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _countryCode = '+91';

  late AnimationController _particleController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  // Particle positions for floating stars
  final List<StarParticle> _particles = [];

  // API Configuration
  static const String BASE_URL = "https://test.bhagyag.com";
  static const String LOGIN_ENDPOINT = "/api/login/authenticate";

  // Multi-language translations
  Map<String, Map<String, String>> translations = {
    'Hindi': {
      'appName': 'भाग्य जी',
      'astrologerLogin': 'ज्योतिषी लॉगिन',
      'welcome': 'स्वागत है',
      'phoneNumber': 'फ़ोन नंबर',
      'password': 'पासवर्ड',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'login': 'लॉगिन',
      'noAccount': 'खाता नहीं है?',
      'signUp': 'साइन अप करें',
      'enterPhone': 'कृपया अपना फोन नंबर दर्ज करें',
      'enterPassword': 'कृपया पासवर्ड दर्ज करें',
      'continueAsAstrologer': 'ज्योतिषी के रूप में जारी रखें',
      'loggingIn': 'लॉगिन हो रहा है...',
      'loginSuccess': 'लॉगिन सफल!',
      'loginFailed': 'लॉगिन विफल',
      'invalidCredentials': 'गलत फ़ोन नंबर या पासवर्ड',
      'notAstrologer': 'आप ज्योतिषी नहीं हैं',
      'accountInactive': 'आपका खाता निष्क्रिय है',
      'networkError': 'नेटवर्क त्रुटि। कृपया पुनः प्रयास करें',
    },
    'English': {
      'appName': 'Bhagya G',
      'astrologerLogin': 'Astrologer Login',
      'welcome': 'Welcome Back',
      'phoneNumber': 'Phone Number',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'login': 'Login',
      'noAccount': "Don't have an account?",
      'signUp': 'Sign Up',
      'enterPhone': 'Please enter phone number',
      'enterPassword': 'Please enter password',
      'continueAsAstrologer': 'Continue as Astrologer',
      'loggingIn': 'Logging in...',
      'loginSuccess': 'Login Successful!',
      'loginFailed': 'Login Failed',
      'invalidCredentials': 'Invalid phone number or password',
      'notAstrologer': 'You are not an astrologer',
      'accountInactive': 'Your account is inactive',
      'networkError': 'Network error. Please try again',
    },
    'Punjabi': {
      'appName': 'ਭਾਗਿਆ ਜੀ',
      'astrologerLogin': 'ਜੋਤਸ਼ੀ ਲਾਗਿਨ',
      'welcome': 'ਸੁਆਗਤ ਹੈ',
      'phoneNumber': 'ਫ਼ੋਨ ਨੰਬਰ',
      'password': 'ਪਾਸਵਰਡ',
      'forgotPassword': 'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ?',
      'login': 'ਲਾਗਿਨ',
      'noAccount': 'ਖਾਤਾ ਨਹੀਂ ਹੈ?',
      'signUp': 'ਸਾਈਨ ਅੱਪ',
      'enterPhone': 'ਕਿਰਪਾ ਕਰਕੇ ਫ਼ੋਨ ਨੰਬਰ ਦਰਜ ਕਰੋ',
      'enterPassword': 'ਕਿਰਪਾ ਕਰਕੇ ਪਾਸਵਰਡ ਦਰਜ ਕਰੋ',
      'continueAsAstrologer': 'ਜੋਤਸ਼ੀ ਵਜੋਂ ਜਾਰੀ ਰੱਖੋ',
      'loggingIn': 'ਲਾਗਇਨ ਹੋ ਰਿਹਾ ਹੈ...',
      'loginSuccess': 'ਲਾਗਇਨ ਸਫਲ!',
      'loginFailed': 'ਲਾਗਇਨ ਅਸਫਲ',
      'invalidCredentials': 'ਗਲਤ ਫ਼ੋਨ ਨੰਬਰ ਜਾਂ ਪਾਸਵਰਡ',
      'notAstrologer': 'ਤੁਸੀਂ ਜੋਤਸ਼ੀ ਨਹੀਂ ਹੋ',
      'accountInactive': 'ਤੁਹਾਡਾ ਖਾਤਾ ਨਿਸ਼ਕਿਰਿਆ ਹੈ',
      'networkError': 'ਨੈੱਟਵਰਕ ਗਲਤੀ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
    },
    'Gujarati': {
      'appName': 'ભાગ્ય જી',
      'astrologerLogin': 'જ્યોતિષી લોગિન',
      'welcome': 'સ્વાગત છે',
      'phoneNumber': 'ફોન નંબર',
      'password': 'પાસવર્ડ',
      'forgotPassword': 'પાસવર્ડ ભૂલી ગયા?',
      'login': 'લોગિન',
      'noAccount': 'એકાઉન્ટ નથી?',
      'signUp': 'સાઇન અપ',
      'enterPhone': 'કૃપા કરીને ફોન નંબર દાખલ કરો',
      'enterPassword': 'કૃપા કરીને પાસવર્ડ દાખલ કરો',
      'continueAsAstrologer': 'જ્યોતિષી તરીકે ચાલુ રાખો',
      'loggingIn': 'લોગિન થઈ રહ્યું છે...',
      'loginSuccess': 'લોગિન સફળ!',
      'loginFailed': 'લોગિન નિષ્ફળ',
      'invalidCredentials': 'અમાન્ય ફોન નંબર અથવા પાસવર્ડ',
      'notAstrologer': 'તમે જ્યોતિષી નથી',
      'accountInactive': 'તમારું એકાઉન્ટ નિષ્ક્રિય છે',
      'networkError': 'નેટવર્ક ભૂલ. કૃપા કરીને ફરી પ્રયાસ કરો',
    },
  };

  @override
  void initState() {
    super.initState();

    // Initialize particles
    for (int i = 0; i < 30; i++) {
      _particles.add(StarParticle());
    }

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Rotation animation for zodiac wheel
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    // Pulse animation for logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _particleController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return translations[widget.selectedLanguageName]?[key] ??
        translations['English']![key]!;
  }

  // API Login Function
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final response = await _loginAPI(phone, password);

        if (response['success']) {
          await _saveUserData(response['data']);

          _showSnackBar(
            _getText('loginSuccess'),
            Colors.green.shade600,
            Icons.check_circle,
          );

          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AstrologerDashboardScreen(),
              ),
            );
          }
        } else {
          _showSnackBar(
            response['message'] ?? _getText('loginFailed'),
            Colors.red.shade600,
            Icons.error,
          );
        }
      } catch (e) {
        _showSnackBar(
          _getText('networkError'),
          Colors.red.shade600,
          Icons.error,
        );
        print('Login error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> _loginAPI(String phone, String password) async {
    try {
      final url = Uri.parse('$BASE_URL$LOGIN_ENDPOINT');

      final requestBody = {
        'loginFrom': 'App',
        'password': password,
        'userName': phone,
        'userType': 'user',
      };

      print('Login Request: $requestBody');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final record = jsonResponse['record'];
        final userType = record['userType']?.toString().toUpperCase();
        final userStatus = record['userStatus']?.toString().toUpperCase();

        if (userType == 'ASTROLOGER' && userStatus == 'ACTIVE') {
          return {
            'success': true,
            'message': _getText('loginSuccess'),
            'data': {
              'userId': record['userId'],
              'fullName': record['fullName'],
              'phoneNo': record['phoneNo'],
              'emailId': record['emailId'],
              'profileImage': record['profileImage'],
              'uniqueUserID': record['uniqueUserID'],
              'userType': record['userType'],
              'userStatus': record['userStatus'],
              'token': jsonResponse['token'],
            },
          };
        } else if (userType != 'ASTROLOGER') {
          return {
            'success': false,
            'message': _getText('notAstrologer'),
          };
        } else if (userStatus != 'ACTIVE') {
          return {
            'success': false,
            'message': _getText('accountInactive'),
          };
        } else {
          return {
            'success': false,
            'message': _getText('invalidCredentials'),
          };
        }
      } else {
        return {
          'success': false,
          'message': _getText('invalidCredentials'),
        };
      }
    } catch (e) {
      print('API Error: $e');
      return {
        'success': false,
        'message': _getText('networkError'),
      };
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', userData['userId'] ?? '');
    await prefs.setString('fullName', userData['fullName'] ?? '');
    await prefs.setString('phoneNo', userData['phoneNo'] ?? '');
    await prefs.setString('emailId', userData['emailId'] ?? '');
    await prefs.setString('profileImage', userData['profileImage'] ?? '');
    await prefs.setString('uniqueUserID', userData['uniqueUserID'] ?? '');
    await prefs.setString('userType', userData['userType'] ?? '');
    await prefs.setString('token', userData['token'] ?? '');
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isAstrologer', true);

    print('User data saved to SharedPreferences');
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AstrologerRegistrationStep1(
          selectedLanguageId: widget.selectedLanguageId,
          selectedLanguageName: widget.selectedLanguageName,
        ),
      ),
    );
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(
      context,
      '/forgot_password',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildParticles(),
          _buildZodiacWheel(),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 550 : size.width,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 40.0 : 24.0,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isWeb ? 50 : 40),

                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildPremiumLogo(),
                          ),

                          SizedBox(height: isWeb ? 30 : 24),

                          _buildAppName(),

                          SizedBox(height: isWeb ? 16 : 12),

                          _buildAstrologerBadge(),

                          SizedBox(height: isWeb ? 60 : 48),

                          _buildGlassMorphicCard(),

                          SizedBox(height: isWeb ? 50 : 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(isWeb && screenWidth > 600 ? 40 : 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: isWeb && screenWidth > 600 ? 50 : 40,
                height: isWeb && screenWidth > 600 ? 50 : 40,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: isWeb ? 24 : 20),
              Text(
                _getText('loggingIn'),
                style: TextStyle(
                  fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A0E2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF1A0E2E),
                  const Color(0xFF2D1B4E),
                  (_particleController.value * 2) % 1,
                )!,
                Color.lerp(
                  const Color(0xFF2D1B4E),
                  const Color(0xFF3D2463),
                  (_particleController.value * 2) % 1,
                )!,
                Color.lerp(
                  const Color(0xFF4A2C78),
                  const Color(0xFF6B3FA0),
                  (_particleController.value * 2) % 1,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animationValue: _particleController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildZodiacWheel() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final wheelSize = isWeb && screenWidth > 600 ? 350.0 : 300.0;

    return Positioned(
      top: -100,
      right: -100,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: 0.08,
              child: Container(
                width: wheelSize,
                height: wheelSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: ZodiacWheelPainter(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumLogo() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final outerSize = isWeb && screenWidth > 600 ? 200.0 : 180.0;
    final middleSize = isWeb && screenWidth > 600 ? 180.0 : 160.0;
    final mainSize = isWeb && screenWidth > 600 ? 150.0 : 130.0;
    final innerSize = isWeb && screenWidth > 600 ? 130.0 : 110.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: outerSize + (_pulseAnimation.value * 20),
              height: outerSize + (_pulseAnimation.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFD700)
                        .withOpacity(0.3 * (1 - _pulseAnimation.value)),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),

        // Middle glow
        Container(
          width: middleSize,
          height: middleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD700).withOpacity(0.4),
                const Color(0xFFFF6B35).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Main logo container
        Container(
          width: mainSize,
          height: mainSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFFA500),
                Color(0xFFFF8C00),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.6),
                blurRadius: isWeb ? 35 : 40,
                spreadRadius: isWeb ? 8 : 10,
              ),
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.4),
                blurRadius: isWeb ? 50 : 60,
                spreadRadius: isWeb ? 12 : 15,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF8DC)],
                ).createShader(bounds),
                child: Image.asset(
                  'assets/images/bhagya.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppName() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFFFFD700),
          Color(0xFFFFA500),
          Color(0xFFFFD700),
        ],
      ).createShader(bounds),
      child: Text(
        _getText('appName'),
        style: TextStyle(
          fontSize: isWeb && screenWidth > 600 ? 42 : 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 3,
          shadows: const [
            Shadow(
              color: Color(0xFFFFD700),
              blurRadius: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologerBadge() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb && screenWidth > 600 ? 28 : 24,
        vertical: isWeb && screenWidth > 600 ? 12 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars,
            color: const Color(0xFFFFD700),
            size: isWeb && screenWidth > 600 ? 26 : 22,
          ),
          SizedBox(width: isWeb ? 12 : 10),
          Text(
            _getText('astrologerLogin'),
            style: TextStyle(
              fontSize: isWeb && screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: isWeb ? 12 : 10),
          Icon(
            Icons.stars,
            color: const Color(0xFFFFD700),
            size: isWeb && screenWidth > 600 ? 26 : 22,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMorphicCard() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(isWeb && screenWidth > 600 ? 40 : 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _getText('welcome'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWeb && screenWidth > 600 ? 24 : 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: isWeb ? 40 : 32),

                  _buildPremiumPhoneField(),

                  SizedBox(height: isWeb ? 28 : 24),

                  _buildPremiumPasswordField(),

                  SizedBox(height: isWeb ? 20 : 16),

                  SizedBox(height: isWeb ? 40 : 32),

                  _buildPremiumLoginButton(),

                  SizedBox(height: isWeb ? 32 : 28),

                  _buildSignUpSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPhoneField() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: isWeb && screenWidth > 600 ? 20 : 16,
                    right: isWeb && screenWidth > 600 ? 12 : 8,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _countryCode,
                        icon: Icon(
                          Icons.arrow_drop_down_circle,
                          color: Colors.white.withOpacity(0.8),
                          size: isWeb && screenWidth > 600 ? 22 : 20,
                        ),
                        dropdownColor: const Color(0xFF2D1B4E),
                        borderRadius: BorderRadius.circular(12),
                        items: [
                          '+91',
                          '+1',
                          '+44',
                          '+971',
                          '+61',
                        ].map((String code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(
                              code,
                              style: TextStyle(
                                fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _countryCode = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 1.5,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      hintText: _getText('phoneNumber'),
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isWeb && screenWidth > 600 ? 16 : 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.phone_android_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: isWeb && screenWidth > 600 ? 24 : 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isWeb && screenWidth > 600 ? 20 : 16,
                        vertical: isWeb && screenWidth > 600 ? 20 : 18,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return _getText('enterPhone');
                      }
                      if (value.length < 10) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPasswordField() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isLoading,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              decoration: InputDecoration(
                hintText: _getText('password'),
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isWeb && screenWidth > 600 ? 16 : 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: isWeb && screenWidth > 600 ? 24 : 22,
                ),
                suffixIcon: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: isWeb && screenWidth > 600 ? 24 : 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isWeb && screenWidth > 600 ? 24 : 20,
                  vertical: isWeb && screenWidth > 600 ? 20 : 18,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _getText('enterPassword');
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumLoginButton() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = isWeb && screenWidth > 600 ? 64.0 : 60.0;

    return MouseRegion(
      cursor: _isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFFA500),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.5),
              blurRadius: isWeb ? 20 : 25,
              offset: Offset(0, isWeb ? 8 : 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleLogin,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getText('login'),
                    style: TextStyle(
                      fontSize: isWeb && screenWidth > 600 ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A0E2E),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: const Color(0xFF1A0E2E),
                    size: isWeb && screenWidth > 600 ? 28 : 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getText('noAccount'),
          style: TextStyle(
            fontSize: isWeb && screenWidth > 600 ? 16 : 15,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TextButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              _getText('signUp'),
              style: TextStyle(
                fontSize: isWeb && screenWidth > 600 ? 16 : 15,
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Color(0xFFFFD700),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// [Keep all helper classes unchanged - StarParticle, ParticlePainter, ZodiacWheelPainter]

class StarParticle {
  late double x;
  late double y;
  late double size;
  late double speedX;
  late double speedY;
  late double opacity;

  StarParticle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 3 + 1;
    speedX = (random.nextDouble() - 0.5) * 0.0005;
    speedY = random.nextDouble() * 0.0008;
    opacity = random.nextDouble() * 0.5 + 0.3;
  }

  void update() {
    x += speedX;
    y += speedY;

    if (y > 1) {
      y = 0;
      x = math.Random().nextDouble();
    }
    if (x > 1) x = 0;
    if (x < 0) x = 1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<StarParticle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();

      paint.color = Colors.white.withOpacity(particle.opacity);

      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.drawCircle(center, particle.size, paint);

      paint.color = const Color(0xFFFFD700).withOpacity(particle.opacity * 0.3);
      canvas.drawCircle(center, particle.size * 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class ZodiacWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final x = center.dx + radius * 0.8 * math.cos(angle);
      final y = center.dy + radius * 0.8 * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 3, paint);

      canvas.drawLine(
        center,
        Offset(x, y),
        paint..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(ZodiacWheelPainter oldDelegate) => false;
}

class AstrologerRegistrationSuccessScreen extends StatelessWidget {
  const AstrologerRegistrationSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B35),
              const Color(0xFFE63946),
              const Color(0xFFD62828),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 500 : screenWidth,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 40 : 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: isWeb && screenWidth > 600 ? 120 : 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: isWeb ? 32 : 24),
                    Text(
                      'Registration Successful!',
                      style: TextStyle(
                        fontSize: isWeb && screenWidth > 600 ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isWeb ? 20 : 16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 40 : 20,
                      ),
                      child: Text(
                        'Your astrologer profile has been submitted successfully.',
                        style: TextStyle(
                          fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: isWeb ? 50 : 40),
                    SizedBox(
                      width: double.infinity,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EnhancedAstrologerLoginScreen(
                                  selectedLanguageId: 1,
                                  selectedLanguageName: 'English',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFE63946),
                            padding: EdgeInsets.symmetric(
                              horizontal: isWeb ? 50 : 40,
                              vertical: isWeb && screenWidth > 600 ? 18 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Go to Login',
                            style: TextStyle(
                              fontSize: isWeb && screenWidth > 600 ? 20 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}