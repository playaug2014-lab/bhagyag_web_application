import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'account_choose_screen.dart';

/// Language Selection Screen
/// Features:
/// - Internet connectivity check
/// - API integration
/// - Beautiful grid layout
/// - Single language selection
/// - Smooth animations
/// - Responsive design for web and mobile
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<Language> _languages = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int? _selectedLanguageId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _checkInternetAndLoadLanguages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkInternetAndLoadLanguages() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // 🔥 WEB: Skip internet check, go directly to loading languages
    if (kIsWeb) {
      await _loadLanguages();
      return;
    }

    // Mobile: Check internet first
    bool hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      _showNoInternetDialog();
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'No internet connection';
      });
      return;
    }

    // Load languages from API
    await _loadLanguages();
  }

  Future<bool> _checkInternetConnection() async {
    // 🔥 Skip on web - always return true
    if (kIsWeb) return true;

    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://test.bhagyag.com/api/Language'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _languages = data
              .map((json) => Language.fromJson(json))
              .where((lang) => lang.languageStatus == 'Active')
              .toList();
          _isLoading = false;
          _hasError = false;
        });
        _animationController.forward();
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      print('❌ Error loading languages: $e');

      // 🔥 WEB FALLBACK: Use hardcoded languages if API fails
      if (kIsWeb) {
        _loadFallbackLanguages();
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load languages. Please try again.';
        });
        _showErrorDialog();
      }
    }
  }

  // 🔥 NEW: Fallback languages for web
  void _loadFallbackLanguages() {
    setState(() {
      _languages = [
        Language(languageId: 1, languageName: 'Hindi', languageStatus: 'Active'),
        Language(languageId: 2, languageName: 'English', languageStatus: 'Active'),
        Language(languageId: 3, languageName: 'Punjabi', languageStatus: 'Active'),
        Language(languageId: 4, languageName: 'Gujarati', languageStatus: 'Active'),
        Language(languageId: 5, languageName: 'Bengali', languageStatus: 'Active'),
        Language(languageId: 6, languageName: 'Marathi', languageStatus: 'Active'),
        Language(languageId: 7, languageName: 'Telugu', languageStatus: 'Active'),
        Language(languageId: 8, languageName: 'Tamil', languageStatus: 'Active'),
      ];
      _isLoading = false;
      _hasError = false;
    });
    _animationController.forward();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Using offline language list'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoInternetDialog(
        onRetry: () {
          Navigator.of(context).pop();
          _checkInternetAndLoadLanguages();
        },
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        message: _errorMessage,
        onRetry: () {
          Navigator.of(context).pop();
          _checkInternetAndLoadLanguages();
        },
      ),
    );
  }

  void _selectLanguage(Language language) {
    setState(() {
      _selectedLanguageId = language.languageId;
    });
  }

  void _continueToApp() async {
    if (_selectedLanguageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a language'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final selectedLanguage = _languages.firstWhere(
          (lang) => lang.languageId == _selectedLanguageId,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AccountChooseScreen(
          selectedLanguageId: _selectedLanguageId!,
          selectedLanguageName: selectedLanguage.languageName,
        ),
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
              const Color(0xFF1A237E),
              const Color(0xFF0D47A1),
              const Color(0xFF01579B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 900 : size.width,
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _hasError
                        ? _buildErrorState()
                        : _buildLanguageGrid(),
                  ),
                  if (!_isLoading && !_hasError) _buildContinueButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          const Icon(
            Icons.language,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose Your Language',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred language',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading languages...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _checkInternetAndLoadLanguages,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A237E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate columns based on width
          int columns;
          double cardWidth;

          if (kIsWeb) {
            if (constraints.maxWidth > 800) {
              columns = 4;
              cardWidth = 160;
            } else if (constraints.maxWidth > 600) {
              columns = 3;
              cardWidth = 140;
            } else {
              columns = 2;
              cardWidth = 140;
            }
          } else {
            columns = 2;
            cardWidth = 140;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: List.generate(_languages.length, (index) {
                return SizedBox(
                  width: cardWidth,
                  child: _buildLanguageCard(_languages[index], index),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageCard(Language language, int index) {
    final isSelected = _selectedLanguageId == language.languageId;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _selectLanguage(language),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 140,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFA726),
                  const Color(0xFFFF6F00),
                ],
              )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFFFFA726).withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getLanguageEmoji(language.languageName),
                        style: const TextStyle(fontSize: 44),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        language.languageName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFFFF6F00),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          gradient: _selectedLanguageId != null
              ? const LinearGradient(
            colors: [
              Color(0xFFFFA726),
              Color(0xFFFF6F00),
            ],
          )
              : LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: _selectedLanguageId != null
              ? [
            BoxShadow(
              color: const Color(0xFFFFA726).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _continueToApp,
            borderRadius: BorderRadius.circular(28),
            child: MouseRegion(
              cursor: _selectedLanguageId != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: _selectedLanguageId != null
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _selectedLanguageId != null
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      size: 24,
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

  String _getLanguageEmoji(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'hindi':
        return '🇮🇳';
      case 'english':
        return '🇬🇧';
      case 'punjabi':
        return '👳';
      case 'gujarati':
        return '🪔';
      case 'bengali':
        return '🐯';
      case 'marathi':
        return '⚡';
      case 'telugu':
        return '🎭';
      case 'tamil':
        return '🌴';
      case 'odia':
        return '🏛️';
      case 'rajasthani':
        return '🐪';
      case 'marwari':
        return '🏰';
      case 'assamese':
        return '🦏';
      default:
        return '🌐';
    }
  }
}

// Language Model
class Language {
  final int languageId;
  final String languageName;
  final String languageStatus;

  Language({
    required this.languageId,
    required this.languageName,
    required this.languageStatus,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      languageId: json['languageId'],
      languageName: json['languageName'],
      languageStatus: json['languageStatus'],
    );
  }
}

// No Internet Dialog
class NoInternetDialog extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetDialog({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE53935),
              Color(0xFFC62828),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your internet connection and try again.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE53935),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error Dialog
class ErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDialog({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFB8C00),
              Color(0xFFF57C00),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFB8C00),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}