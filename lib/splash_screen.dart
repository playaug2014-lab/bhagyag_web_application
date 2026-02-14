import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'sliderscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade animation for logo
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation for logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Slide animation for text
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _animationController.forward();

    // Show button after animation completes
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });

    // Auto navigate after 4 seconds (optional)
    // Timer(const Duration(seconds: 4), () {
    //   _navigateToHome();
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    // Navigate to onboarding screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    // Responsive sizing
    final logoSize = isWeb && size.width > 600 ? 260.0 : 220.0;
    final titleSize = isWeb && size.width > 600 ? 48.0 : 42.0;
    final descriptionSize = isWeb && size.width > 600 ? 18.0 : 16.0;
    final buttonHeight = isWeb && size.width > 600 ? 64.0 : 56.0;
    final buttonTextSize = isWeb && size.width > 600 ? 22.0 : 20.0;
    final iconSize = isWeb && size.width > 600 ? 28.0 : 24.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF5E6),
              const Color(0xFFFFE6D6),
              const Color(0xFFFFD4C4),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern/image
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/bhagya.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Decorative circles - responsive sizing
            Positioned(
              top: -50,
              right: -50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: isWeb && size.width > 600 ? 240 : 200,
                  height: isWeb && size.width > 600 ? 240 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA61C0A).withOpacity(0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: isWeb && size.width > 600 ? 300 : 250,
                  height: isWeb && size.width > 600 ? 300 : 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA61C0A).withOpacity(0.08),
                  ),
                ),
              ),
            ),

            // Main content - centered with max width
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 600 : size.width,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 40.0 : 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Animated Logo/GIF
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFA61C0A).withOpacity(0.3),
                                    blurRadius: isWeb ? 25 : 30,
                                    spreadRadius: isWeb ? 3 : 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/bhagya.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isWeb ? 50 : 40),

                        // App name
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFA61C0A),
                                  Color(0xFFD32F2F),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'Bhagya G',
                                style: TextStyle(
                                  fontFamily: 'BreeSerif',
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isWeb ? 24 : 20),

                        // Description
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWeb ? 40.0 : 30.0,
                              ),
                              child: Text(
                                'Your personal horoscope in your mobile.\nKnow more about yourself with our expert calculation.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: descriptionSize,
                                  color: Colors.black87,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Get Started Button
                        AnimatedOpacity(
                          opacity: _showButton ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          child: AnimatedSlide(
                            offset: _showButton ? Offset.zero : const Offset(0, 0.3),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            child: MouseRegion(
                              cursor: _showButton
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                              child: Container(
                                width: double.infinity,
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFA61C0A),
                                      Color(0xFFD32F2F),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFA61C0A).withOpacity(0.4),
                                      blurRadius: isWeb ? 15 : 20,
                                      offset: Offset(0, isWeb ? 6 : 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _showButton ? _navigateToHome : null,
                                    borderRadius: BorderRadius.circular(buttonHeight / 2),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: buttonTextSize,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: iconSize,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isWeb ? 50 : 40),

                        // Loading indicator (optional)
                        if (!_showButton)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: isWeb ? 35 : 30,
                              height: isWeb ? 35 : 30,
                              child: CircularProgressIndicator(
                                strokeWidth: isWeb ? 2.5 : 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFA61C0A),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(height: isWeb ? 40 : 30),
                      ],
                    ),
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