import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_registration_screen.dart';
import 'user_dashboard.dart';
import 'otp_screen.dart';

/// Enhanced Login Screen with Wallet Balance Fetch
class EnhancedLoginScreen extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;
  final int accountType;

  const EnhancedLoginScreen({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
    required this.accountType,
  }) : super(key: key);

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _countryCode = '+91';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasShownPromo = false;

  static const String API_BASE_URL = 'https://test.bhagyag.com/api';
  static const String LOGIN_ENDPOINT = '/Login/authenticate';
  static const String USER_LIST_ENDPOINT = '/User';
  static const String WALLET_ENDPOINT = '/Wallet';
  static const String SKIP_PHONE = '9999999999';
  static const String SKIP_PASSWORD = 'User@123';

  Map<String, Map<String, String>> translations = {
    'Hindi': {
      'appName': 'भाग्य जी',
      'welcome': 'स्वागत है',
      'phoneNumber': 'फ़ोन नंबर',
      'password': 'पासवर्ड',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'login': 'लॉगिन',
      'skip': 'छोड़ें',
      'noAccount': 'खाता नहीं है?',
      'signUp': 'साइन अप करें',
      'enterPhone': 'कृपया अपना फोन नंबर दर्ज करें',
      'enterPassword': 'कृपया पासवर्ड दर्ज करें',
      'terms': 'साइन अप करके, आप हमारी सेवा की शर्तें और गोपनीयता नीति से सहमत हैं',
      'termsOfUse': 'सेवा की शर्तें',
      'privacyPolicy': 'गोपनीयता नीति',
      'loggingIn': 'लॉगिन हो रहा है...',
      'loginSuccess': 'लॉगिन सफल!',
      'loginFailed': 'लॉगिन विफल',
      'fillAllFields': 'कृपया सभी फ़ील्ड भरें',
      'invalidCredentials': 'गलत फ़ोन या पासवर्ड',
      'userNotFound': 'उपयोगकर्ता नहीं मिला',
      'alreadyRegistered': 'पहले से पंजीकृत',
      'phoneNotRegistered': 'फ़ोन पंजीकृत नहीं है',
      'enterMobile': 'अपना मोबाइल नंबर दर्ज करें',
    },
    'English': {
      'appName': 'Bhagya G',
      'welcome': 'Welcome Back',
      'phoneNumber': 'Phone Number',
      'password': 'Password',
      'forgotPassword': 'Forgot Password?',
      'login': 'Login',
      'skip': 'Skip',
      'noAccount': "Don't have an account?",
      'signUp': 'Sign Up',
      'enterPhone': 'Please enter phone number',
      'enterPassword': 'Please enter password',
      'terms': 'By signing up, you agree to our Terms of Use and Privacy Policy',
      'termsOfUse': 'Terms of Use',
      'privacyPolicy': 'Privacy Policy',
      'loggingIn': 'Logging in...',
      'loginSuccess': 'Login successful!',
      'loginFailed': 'Login failed',
      'fillAllFields': 'Please fill all fields',
      'invalidCredentials': 'Incorrect phone or password',
      'userNotFound': 'User not found',
      'alreadyRegistered': 'Already registered',
      'phoneNotRegistered': 'Phone not registered',
      'enterMobile': 'Enter your mobile number',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getText(String key) {
    return translations[widget.selectedLanguageName]?[key] ??
        translations['English']![key]!;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final phone = _phoneController.text;
      final password = _passwordController.text;

      try {
        final response = await _loginAPI(phone, password);

        if (response != null) {
          final userType = response['record']['userType'];
          final userStatus = response['record']['userStatus'];
          final userId = response['record']['userId'];

          if (userStatus == 'Active') {
            if (userType.toString().toUpperCase() == 'USER' && widget.accountType == 2) {
              await _saveUserSession(response['record']);
              final walletAmount = await _fetchWalletBalance(userId);
              _navigateToUserDashboard(response['record'], walletAmount);
            } else if (userType == 'ASTROLOGER' && widget.accountType == 1) {
              await _saveAstrologerSession(response['record']);
              _navigateToAstrologerDashboard(response['record']);
            } else {
              _showError('Account type mismatch');
            }
          } else {
            _showError('Account is not active');
          }
        } else {
          _showError(_getText('invalidCredentials'));
        }
      } catch (e) {
        print('Login Error: $e');
        _showError('Something went wrong. Try again later');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _loginAPI(String phone, String password) async {
    try {
      final url = Uri.parse('$API_BASE_URL$LOGIN_ENDPOINT');
      final requestBody = {
        'loginFrom': 'App',
        'password': password,
        'userName': phone,
        'userType': widget.accountType == 1 ? 'ASTROLOGER' : 'user',
      };

      print('Login Request: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Login Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Login API Error: $e');
      return null;
    }
  }

  Future<String> _fetchWalletBalance(String userId) async {
    try {
      print('Fetching wallet balance for userId: $userId');

      final url = Uri.parse('$API_BASE_URL$WALLET_ENDPOINT/$userId');
      final response = await http.get(url);

      print('Wallet API Response: ${response.statusCode}');
      print('Wallet Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final walletData = json.decode(response.body);
        final balance = (walletData['balance'] ?? 0.0).toDouble();
        final formattedAmount = '₹${balance.toStringAsFixed(2)}';

        print('✅ Wallet balance fetched: $formattedAmount');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('walletAmount', formattedAmount);

        return formattedAmount;
      } else {
        print('⚠️ Wallet API failed with status: ${response.statusCode}');
        return '₹0.00';
      }
    } catch (e) {
      print('❌ Error fetching wallet balance: $e');
      return '₹0.00';
    }
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userData['userId'] ?? '');
    await prefs.setString('fullName', userData['fullName'] ?? '');
    await prefs.setString('phoneNo', userData['phoneNo'] ?? '');
    await prefs.setString('uniqueUserID', userData['uniqueUserID'] ?? '');
    await prefs.setString('userType', 'USER');
    await prefs.setString('email', userData['emailId'] ?? '');
    await prefs.setString('gender', userData['gender'] ?? 'Male');

    String dobDate = '';
    String tobTime = '';
    if (userData['dob'] != null) {
      try {
        DateTime dt = DateTime.parse(userData['dob']);
        dobDate = DateFormat('yyyy-MM-dd').format(dt);
        tobTime = DateFormat('hh:mm a').format(dt);
      } catch (e) {
        dobDate = '';
        tobTime = '';
      }
    }

    await prefs.setString('dob', dobDate);
    await prefs.setString('tob', tobTime);
    await prefs.setString('placeOfBirth', userData['placeOfBirth'] ?? '');
    await prefs.setString('address', userData['currentAddress'] ?? '');
    await prefs.setString('district', userData['district'] ?? '');
    await prefs.setString('state', userData['state'] ?? '');
    await prefs.setString('pincode', userData['pincode'] ?? '');
    await prefs.setBool('myboolean', true);

    print('✅ User session saved');
  }

  Future<void> _saveAstrologerSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userData['userId'] ?? '');
    await prefs.setString('fullName', userData['fullName'] ?? '');
    await prefs.setString('phoneNo', userData['phoneNo'] ?? '');
    await prefs.setString('uniqueUserID', userData['uniqueUserID'] ?? '');
    await prefs.setString('userType', 'ASTROLOGER');
  }

  void _navigateToUserDashboard(Map<String, dynamic> userData, String walletAmount) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UserDashboard(
          userName: userData['fullName'] ?? 'User',
          walletAmount: walletAmount,
        ),
      ),
    );
    _showSuccess(_getText('loginSuccess'));
  }

  void _navigateToAstrologerDashboard(Map<String, dynamic> userData) {
    _showSuccess('Astrologer login successful!');
  }

  Future<void> _handleSkipLogin() async {
    setState(() {
      _isLoading = true;
    });
    _phoneController.text = SKIP_PHONE;
    _passwordController.text = SKIP_PASSWORD;
    await _handleLogin();
  }

  Future<void> _handleForgotPassword() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError(_getText('enterMobile'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userExists = await _checkUserExists(_phoneController.text);

      if (userExists != null) {
        final isMobileVerified = userExists['isMobileVerified'];

        if (isMobileVerified == 'Y') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userid', userExists['userId'] ?? '');
          await prefs.setString('password', userExists['password'] ?? '');

          _navigateToOTPScreen(isForPasswordReset: true);
        } else {
          _showError(_getText('phoneNotRegistered'));
        }
      } else {
        _showError(_getText('userNotFound'));
      }
    } catch (e) {
      print('Forgot password error: $e');
      _showError('Something went wrong');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      _showError(_getText('enterMobile'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userExists = await _checkUserExists(_phoneController.text);

      if (userExists != null) {
        final isMobileVerified = userExists['isMobileVerified'];

        if (isMobileVerified == 'Y') {
          _showError(_getText('alreadyRegistered'));
        } else {
          _showError(_getText('phoneNotRegistered'));
        }
      } else {
        _navigateToRegistration();
      }
    } catch (e) {
      print('Sign up check error: $e');
      _showError('Something went wrong');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _checkUserExists(String phoneNo) async {
    try {
      final url = Uri.parse('$API_BASE_URL$USER_LIST_ENDPOINT');
      final response = await http.get(url);

      print('User List Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> userList = json.decode(response.body);

        for (var user in userList) {
          if (user['phoneNo'] == phoneNo) {
            print('User found: ${user['fullName']}, Verified: ${user['isMobileVerified']}');
            return user;
          }
        }

        print('No user found with phone: $phoneNo');
        return null;
      }

      print('Failed to fetch user list: ${response.statusCode}');
      return null;
    } catch (e) {
      print('User Check API Error: $e');
      return null;
    }
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserRegistrationScreen(
          selectedLanguageId: widget.selectedLanguageId,
          selectedLanguageName: widget.selectedLanguageName,
          phoneNumber: _phoneController.text,
        ),
      ),
    );
  }

  void _navigateToOTPScreen({bool isForPasswordReset = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OtpScreen(
          phoneNumber: _phoneController.text,
          isForPasswordReset: isForPasswordReset,
          isForRegistration: false,
        ),
      ),
    );
  }

  Future<void> _openTermsOfUse() async {
    final url = Uri.parse('https://bhagyag.com/pages/terms-of-service');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://bhagyag.com/policies/privacy-policy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF5E6),
              const Color(0xFFFFE6D6),
              const Color(0xFFFFD4C4),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWeb ? 500 : size.width,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 40.0 : 24.0,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            SizedBox(height: isWeb ? 30 : 20),
                            _buildSkipButton(),
                            SizedBox(height: isWeb ? 30 : 20),
                            _buildLogo(),
                            SizedBox(height: isWeb ? 20 : 16),
                            Text(
                              _getText('appName'),
                              style: TextStyle(
                                fontSize: isWeb && size.width > 600 ? 36 : 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC32F00),
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getText('welcome'),
                              style: TextStyle(
                                fontSize: isWeb && size.width > 600 ? 18 : 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: isWeb ? 50 : 40),
                            SlideTransition(
                              position: _slideAnimation,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPhoneField(),
                                    const SizedBox(height: 24),
                                    _buildPasswordField(),
                                    const SizedBox(height: 16),
                                    _buildForgotPassword(),
                                    SizedBox(height: isWeb ? 50 : 40),
                                    _buildLoginButton(),
                                    const SizedBox(height: 24),
                                    _buildSignUpLink(),
                                    const SizedBox(height: 24),
                                    _buildTermsAndPrivacy(),
                                    SizedBox(height: isWeb ? 40 : 32),
                                  ],
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
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(isWeb ? 32 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF1A237E),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getText('loggingIn'),
                          style: TextStyle(
                            fontSize: isWeb ? 18 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TextButton(
          onPressed: _handleSkipLogin,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 20 : 16,
              vertical: isWeb ? 12 : 8,
            ),
          ),
          child: Text(
            _getText('skip'),
            style: TextStyle(
              fontSize: isWeb && size.width > 600 ? 18 : 16,
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;
    final logoSize = isWeb && size.width > 600 ? 220.0 : 200.0;

    return Container(
      width: logoSize,
      height: logoSize,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Image.asset(
          'assets/images/bhagya.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC32F00).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 16 : 12,
              ),
              child: DropdownButtonHideUnderline(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: DropdownButton<String>(
                    value: _countryCode,
                    icon: const Icon(Icons.arrow_drop_down, size: 24),
                    items: ['+91', '+1', '+44', '+971', '+61'].map((String code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(
                          code,
                          style: TextStyle(
                            fontSize: isWeb && size.width > 600 ? 18 : 16,
                            fontWeight: FontWeight.w600,
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
              color: const Color(0xFFC32F00).withOpacity(0.3),
            ),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: TextStyle(
                  fontSize: isWeb && size.width > 600 ? 18 : 16,
                ),
                decoration: InputDecoration(
                  hintText: _getText('phoneNumber'),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isWeb && size.width > 600 ? 18 : 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 20 : 16,
                    vertical: isWeb ? 20 : 16,
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
    );
  }

  Widget _buildPasswordField() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC32F00).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(
            fontSize: isWeb && size.width > 600 ? 18 : 16,
          ),
          decoration: InputDecoration(
            hintText: _getText('password'),
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isWeb && size.width > 600 ? 18 : 16,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isWeb ? 24 : 20,
              vertical: isWeb ? 20 : 16,
            ),
            suffixIcon: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFFC32F00),
                  size: isWeb && size.width > 600 ? 26 : 24,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _getText('enterPassword');
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Align(
      alignment: Alignment.centerRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: TextButton(
          onPressed: _handleForgotPassword,
          child: Text(
            _getText('forgotPassword'),
            style: TextStyle(
              fontSize: isWeb && size.width > 600 ? 16 : 14,
              color: const Color(0xFFC32F00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;
    final buttonHeight = isWeb && size.width > 600 ? 60.0 : 56.0;

    return MouseRegion(
      cursor: _isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withOpacity(0.4),
              blurRadius: isWeb ? 12 : 15,
              offset: Offset(0, isWeb ? 6 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleLogin,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getText('login'),
                    style: TextStyle(
                      fontSize: isWeb && size.width > 600 ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: isWeb && size.width > 600 ? 28 : 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getText('noAccount'),
            style: TextStyle(
              fontSize: isWeb && size.width > 600 ? 16 : 15,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: TextButton(
              onPressed: _handleSignUp,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getText('signUp'),
                style: TextStyle(
                  fontSize: isWeb && size.width > 600 ? 16 : 15,
                  color: const Color(0xFFC32F00),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 20 : 0,
            ),
            child: Text(
              _getText('terms'),
              style: TextStyle(
                fontSize: isWeb && size.width > 600 ? 14 : 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: _openTermsOfUse,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _getText('termsOfUse'),
                    style: TextStyle(
                      fontSize: isWeb && size.width > 600 ? 14 : 12,
                      color: const Color(0xFFC32F00),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Text(
                ' | ',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isWeb && size.width > 600 ? 14 : 12,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: _openPrivacyPolicy,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _getText('privacyPolicy'),
                    style: TextStyle(
                      fontSize: isWeb && size.width > 600 ? 14 : 12,
                      color: const Color(0xFFC32F00),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}