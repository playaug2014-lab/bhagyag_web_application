import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_login.dart';
import 'astrologer_login_screen.dart';

/// Account Choose Screen (User / Astrologer)
class AccountChooseScreen extends StatefulWidget {
  final int selectedLanguageId;
  final String selectedLanguageName;

  const AccountChooseScreen({
    Key? key,
    required this.selectedLanguageId,
    required this.selectedLanguageName,
  }) : super(key: key);

  @override
  State<AccountChooseScreen> createState() => _AccountChooseScreenState();
}

class _AccountChooseScreenState extends State<AccountChooseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int? _selectedAccount; // 1 = Astrologer, 2 = User

  // Multi-language translations
  final Map<String, Map<String, String>> translations = {
    'Hindi': {
      'title': 'आप कौन हैं चुनें',
      'astrologer': 'ज्योतिषी',
      'user': 'उपयोगकर्ता',
      'continue': 'जारी रखें',
      'select_msg': 'कृपया खाता प्रकार चुनें',
    },
    'English': {
      'title': 'Choose Who You Are',
      'astrologer': 'Astrologer',
      'user': 'User',
      'continue': 'Continue',
      'select_msg': 'Please select an account type',
    },
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Safe translation getter
  String _getText(String key) {
    final lang = widget.selectedLanguageName.trim();
    return translations[lang]?[key] ?? translations['English']![key]!;
  }

  void _selectAccount(int type) {
    setState(() => _selectedAccount = type);
  }

  Future<void> _continue() async {
    if (_selectedAccount == null) {
      _showError(_getText('select_msg'));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('account_type', _selectedAccount!);

    if (_selectedAccount == 1) {
      // ---- ASTROLOGER LOGIN ----
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedAstrologerLoginScreen(
            selectedLanguageId: widget.selectedLanguageId,
            selectedLanguageName: widget.selectedLanguageName,
          ),
        ),
      );
    } else {
      // ---- USER LOGIN ----
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EnhancedLoginScreen(
            selectedLanguageId: widget.selectedLanguageId,
            selectedLanguageName: widget.selectedLanguageName,
            accountType: _selectedAccount!,
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade400,
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
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFE7D8),
              const Color(0xFFFFD4C4),
              const Color(0xFFFFC2B2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 600 : size.width,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(height: isWeb ? 60 : 40),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 40 : 24,
                      ),
                      child: Text(
                        _getText('title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWeb && size.width > 600 ? 36 : 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFA61C0A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    SizedBox(height: isWeb ? 80 : 60),

                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAccountCard(
                                type: 1,
                                title: _getText('astrologer'),
                                icon: Icons.auto_awesome,
                                colors: const [
                                  Color(0xFF6A1B9A),
                                  Color(0xFF8E24AA),
                                ],
                              ),
                              SizedBox(height: isWeb ? 40 : 30),
                              _buildAccountCard(
                                type: 2,
                                title: _getText('user'),
                                icon: Icons.person,
                                colors: const [
                                  Color(0xFF00796B),
                                  Color(0xFF009688),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Continue Button
                    _buildContinueButton(),

                    SizedBox(height: isWeb ? 50 : 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ ACCOUNT CARD ------------------
  Widget _buildAccountCard({
    required int type,
    required String title,
    required IconData icon,
    required List<Color> colors,
  }) {
    final isSelected = _selectedAccount == type;
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    // Responsive sizing
    final cardHeight = isWeb && size.width > 600 ? 200.0 : 180.0;
    final iconSize = isWeb && size.width > 600 ? 70.0 : 60.0;
    final fontSize = isWeb && size.width > 600 ? 30.0 : 26.0;
    final horizontalPadding = isWeb && size.width > 600 ? 40.0 : 24.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectAccount(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: cardHeight,
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isSelected ? Colors.white : colors[0].withOpacity(0.3),
              width: isSelected ? 4 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? colors[0].withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isSelected ? (isWeb ? 20 : 25) : 12,
                spreadRadius: isSelected ? (isWeb ? 1 : 2) : 0,
                offset: Offset(0, isWeb ? 8 : 10),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: iconSize,
                  color: isSelected ? Colors.white : colors[0],
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : colors[0],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ CONTINUE BUTTON ------------------
  Widget _buildContinueButton() {
    final enabled = _selectedAccount != null;
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    // Responsive sizing
    final buttonHeight = isWeb && size.width > 600 ? 65.0 : 60.0;
    final fontSize = isWeb && size.width > 600 ? 22.0 : 20.0;
    final iconSize = isWeb && size.width > 600 ? 26.0 : 24.0;
    final horizontalPadding = isWeb && size.width > 600 ? 40.0 : 24.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFA61C0A), Color(0xFFD32F2F)],
          )
              : LinearGradient(
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(buttonHeight / 2),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: const Color(0xFFA61C0A).withOpacity(0.4),
              blurRadius: isWeb ? 15 : 20,
              offset: Offset(0, isWeb ? 6 : 8),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? _continue : null,
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            child: MouseRegion(
              cursor: enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getText('continue'),
                      style: TextStyle(
                        color: enabled ? Colors.white : Colors.grey.shade700,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: enabled ? Colors.white : Colors.grey.shade700,
                      size: iconSize,
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