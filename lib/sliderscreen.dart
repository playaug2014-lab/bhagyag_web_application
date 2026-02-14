import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'language_selection_screen.dart';

/// Enhanced Onboarding Screen with 3 Beautiful Slides
/// Slide 1: Talk With Astrologer
/// Slide 2: Palm Reading
/// Slide 3: Love Compatibility
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatingController;
  late AnimationController _rotationController;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Talk With Astrologer',
      description: 'Connect with expert astrologers and get personalized guidance for your life journey. Discover what the stars have in store for you.',
      icon: Icons.chat_bubble_outline_rounded,
      color: Color(0xFFDA922A),
      gradient: [Color(0xFFDA922A), Color(0xFFFFD4C4)],
    ),
    OnboardingSlide(
      title: 'Palm Reading',
      description: 'Unlock the secrets hidden in your palm lines. Get detailed analysis of your past, present, and future through ancient palmistry.',
      icon: Icons.front_hand_rounded,
      color: Color(0xFFD84315),
      gradient: [Color(0xFFFF6F00), Color(0xFFFFD4C4)],
    ),
    OnboardingSlide(
      title: 'Love Compatibility',
      description: 'Discover your perfect match! Check compatibility with your partner based on zodiac signs and planetary positions.',
      icon: Icons.favorite_rounded,
      color: Color(0xFFC2185B),
      gradient: [Color(0xFFE91E63), Color(0xFFFFD4C4)],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToHome();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentPage];
    final size = MediaQuery.of(context).size;
    final isWeb = kIsWeb;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentSlide.gradient[0].withOpacity(0.2),
              const Color(0xFF0F0620),
              const Color(0xFF1A0E2E),
              currentSlide.gradient[1].withOpacity(0.3),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(currentSlide),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 700 : size.width,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: _slides.length,
                          itemBuilder: (context, index) {
                            return _buildSlide(_slides[index], index);
                          },
                        ),
                      ),
                      _buildBottomSection(),
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

  Widget _buildAnimatedBackground(OnboardingSlide slide) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              top: 100 + (_floatingController.value * 50),
              right: isWeb && screenWidth > 600 ? 50 : 30,
              child: Container(
                width: isWeb && screenWidth > 600 ? 140 : 120,
                height: isWeb && screenWidth > 600 ? 140 : 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      slide.color.withOpacity(0.3),
                      slide.color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Positioned(
              bottom: 150 + (_floatingController.value * -40),
              left: isWeb && screenWidth > 600 ? 60 : 40,
              child: Container(
                width: isWeb && screenWidth > 600 ? 180 : 150,
                height: isWeb && screenWidth > 600 ? 180 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      slide.color.withOpacity(0.2),
                      slide.color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Positioned.fill(
              child: CustomPaint(
                painter: StarsPainter(
                  animationValue: _rotationController.value,
                  color: slide.color,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(isWeb && screenWidth > 600 ? 24.0 : 20.0),
      child: Row(
        children: [
          Container(
            width: isWeb && screenWidth > 600 ? 70 : 60,
            height: isWeb && screenWidth > 600 ? 70 : 60,
            child: Image.asset(
              'assets/images/bhagya.png',
              width: isWeb && screenWidth > 600 ? 40 : 32,
              height: isWeb && screenWidth > 600 ? 40 : 32,
            ),
          ),
          SizedBox(width: isWeb ? 16 : 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFC32F00),
                Color(0xFFFF6F00),
              ],
            ).createShader(bounds),
            child: Text(
              'Bhagya G',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: isWeb && screenWidth > 600 ? 30 : 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index) {
    final isActive = _currentPage == index;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final iconContainerSize = isWeb && screenWidth > 600 ? 260.0 : 220.0;
    final iconInnerSize = isWeb && screenWidth > 600 ? 170.0 : 150.0;
    final iconSize = isWeb && screenWidth > 600 ? 85.0 : 75.0;
    final titleSize = isWeb && screenWidth > 600 ? 32.0 : 28.0;
    final descriptionSize = isWeb && screenWidth > 600 ? 16.0 : 14.0;

    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb && screenWidth > 600 ? 40.0 : 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.0 : 0.8,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              child: Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      slide.color.withOpacity(0.4),
                      slide.color.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: slide.color.withOpacity(0.5),
                      blurRadius: isWeb ? 50 : 60,
                      spreadRadius: isWeb ? 15 : 20,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: iconContainerSize * 0.82,
                            height: iconContainerSize * 0.82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: slide.color.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: iconInnerSize,
                      height: iconInnerSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: slide.gradient,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: slide.color.withOpacity(0.6),
                            blurRadius: isWeb ? 25 : 30,
                            spreadRadius: isWeb ? 3 : 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        slide.icon,
                        size: iconSize,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isWeb ? 50 : 40),
            AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: slide.gradient,
                ).createShader(bounds),
                child: Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            SizedBox(height: isWeb ? 20 : 16),
            AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.4),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb && screenWidth > 600 ? 20 : 0,
                ),
                child: Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: descriptionSize,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWeb && screenWidth > 600 ? 40 : 30,
        20,
        isWeb && screenWidth > 600 ? 40 : 30,
        isWeb && screenWidth > 600 ? 40 : 30,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length,
                  (index) => _buildPageIndicator(index),
            ),
          ),
          SizedBox(height: isWeb ? 30 : 25),
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  flex: 1,
                  child: _buildBackButton(),
                ),
              if (_currentPage > 0) SizedBox(width: isWeb ? 20 : 15),
              Expanded(
                flex: _currentPage > 0 ? 2 : 1,
                child: _buildNextButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;
    final currentColor = _slides[_currentPage].color;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: isWeb && screenWidth > 600 ? 6 : 5,
      ),
      width: isActive
          ? (isWeb && screenWidth > 600 ? 50 : 40)
          : (isWeb && screenWidth > 600 ? 12 : 10),
      height: isWeb && screenWidth > 600 ? 12 : 10,
      decoration: BoxDecoration(
        color: isActive ? currentColor : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: currentColor.withOpacity(0.5),
            blurRadius: isWeb ? 8 : 10,
            spreadRadius: isWeb ? 1 : 2,
          ),
        ]
            : [],
      ),
    );
  }

  Widget _buildBackButton() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = isWeb && screenWidth > 600 ? 56.0 : 50.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(buttonHeight / 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _previousPage,
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: isWeb && screenWidth > 600 ? 22 : 20,
                  ),
                  SizedBox(width: isWeb ? 8 : 6),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isWeb && screenWidth > 600 ? 17 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final currentSlide = _slides[_currentPage];
    final isLastPage = _currentPage == _slides.length - 1;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonHeight = isWeb && screenWidth > 600 ? 56.0 : 50.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: currentSlide.gradient,
          ),
          borderRadius: BorderRadius.circular(buttonHeight / 2),
          boxShadow: [
            BoxShadow(
              color: currentSlide.color.withOpacity(0.5),
              blurRadius: isWeb ? 15 : 20,
              offset: Offset(0, isWeb ? 6 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _nextPage,
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb && screenWidth > 600 ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLastPage ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: isWeb && screenWidth > 600 ? 24 : 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  StarsPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (size.width * 0.1 * i + animationValue * 100) % size.width;
      final y = (size.height * 0.15 * i) % size.height;
      final starSize = 2.0 + (i % 3);

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}