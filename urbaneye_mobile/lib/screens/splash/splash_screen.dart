import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _dotController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _bottomFade;

  Timer? _navigationTimer;

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.70)
        : const Color(0xFF5F596B);
  }

  Color _mutedText(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.35)
        : const Color(0xFF8A8492);
  }

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.55,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.0,
        0.40,
        curve: Curves.easeIn,
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.35,
        0.80,
        curve: Curves.easeIn,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(
          0.30,
          0.85,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _bottomFade = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(
        0.65,
        1.0,
        curve: Curves.easeIn,
      ),
    );

    _mainController.forward();

    _navigationTimer = Timer(
      const Duration(seconds: 6),
      _goToOnboarding,
    );
  }

  void _goToOnboarding() {
    if (!mounted) return;

    context.go('/onboarding');
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();

    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _dotController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B0712)
          : const Color(0xFFF8F7FC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF160A2A),
                    Color(0xFF0F081A),
                    Color(0xFF09060F),
                  ]
                : const [
                    Color(0xFFF0E5FA),
                    Color(0xFFF7F3FB),
                    Color(0xFFFFFFFF),
                  ],
            stops: const [
              0.0,
              0.55,
              1.0,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundGlow(context),
            _buildDecorativeRings(context),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  _buildLogo(context),
                  const SizedBox(height: 34),
                  _buildBrandContent(context),
                  const Spacer(),
                  _buildLoadingIndicator(context),
                  const SizedBox(height: 22),
                  _buildBottomText(context),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    final isDark = _isDark(context);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -160,
            left: -100,
            child: _glow(
              size: 360,
              color: const Color(0xFF7C3AED),
              opacity: isDark ? 0.14 : 0.12,
              blur: isDark ? 90 : 110,
            ),
          ),
          Positioned(
            top: 180,
            right: -170,
            child: _glow(
              size: 360,
              color: const Color(0xFF5B21B6),
              opacity: isDark ? 0.12 : 0.07,
              blur: isDark ? 100 : 120,
            ),
          ),
          Positioned(
            bottom: -180,
            left: -130,
            child: _glow(
              size: 400,
              color: const Color(0xFF7C3AED),
              opacity: isDark ? 0.10 : 0.06,
              blur: isDark ? 100 : 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow({
    required double size,
    required Color color,
    required double opacity,
    required double blur,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blur,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeRings(BuildContext context) {
    final isDark = _isDark(context);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Positioned(
            top: 80,
            right: -110,
            child: Transform.rotate(
              angle: _rotationController.value * math.pi * 2,
              child: SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: _RingPainter(
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = _isDark(context);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;

        return FadeTransition(
          opacity: _logoFade,
          child: ScaleTransition(
            scale: _logoScale,
            child: SizedBox(
              width: 154,
              height: 154,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 154 + (pulse * 10),
                    height: 154 + (pulse * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.purple.withValues(
                          alpha: isDark
                              ? 0.08 + (pulse * 0.08)
                              : 0.10 + (pulse * 0.05),
                        ),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 138,
                    height: 138,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF181022)
                          : Colors.white.withValues(alpha: 0.90),
                      border: Border.all(
                        color: AppColors.purple.withValues(
                          alpha: isDark ? 0.25 : 0.20,
                        ),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(
                            alpha: isDark
                                ? 0.16 + (pulse * 0.10)
                                : 0.12 + (pulse * 0.06),
                          ),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.visibility_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  Positioned(
                    top: 17,
                    right: 24,
                    child: _buildScanDot(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanDot(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(
          _dotController.value,
        );

        return Container(
          width: 11 + (value * 4),
          height: 11 + (value * 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isDark(context)
                ? Colors.white
                : AppColors.purple,
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.7),
                blurRadius: 12 + (value * 8),
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrandContent(BuildContext context) {
    final isDark = _isDark(context);

    return SlideTransition(
      position: _contentSlide,
      child: FadeTransition(
        opacity: _contentFade,
        child: Column(
          children: [
            Text(
              'UrbanEye',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                'AI-POWERED CIVIC INTELLIGENCE',
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF6B557D),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38),
              child: Text(
                'Detect. Understand. Improve.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isDark(context)
                      ? Colors.white.withValues(alpha: 0.88)
                      : const Color(0xFF302B38),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                'Smarter technology for better communities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(context),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final isDark = _isDark(context);

    return FadeTransition(
      opacity: _bottomFade,
      child: AnimatedBuilder(
        animation: _dotController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) {
                final animationValue =
                    (_dotController.value + index * 0.2) % 1.0;

                final opacity = 0.25 +
                    (math.sin(
                          animationValue * math.pi,
                        ) *
                        0.75);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: opacity)
                        : AppColors.purple.withValues(alpha: opacity),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomText(BuildContext context) {
    return FadeTransition(
      opacity: _bottomFade,
      child: Column(
        children: [
          Text(
            'SMARTER CITIES • BETTER COMMUNITIES',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _mutedText(context),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Powered by AI',
            style: TextStyle(
              color: _isDark(context)
                  ? Colors.white.withValues(alpha: 0.20)
                  : const Color(0xFF9A92A5),
              fontSize: 9,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final bool isDark;

  _RingPainter({
    required this.isDark,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    paint.color = isDark
        ? Colors.white.withValues(alpha: 0.035)
        : Colors.black.withValues(alpha: 0.035);

    canvas.drawCircle(
      center,
      size.width * 0.35,
      paint,
    );

    paint.color = AppColors.purple.withValues(
      alpha: isDark ? 0.10 : 0.08,
    );

    canvas.drawCircle(
      center,
      size.width * 0.43,
      paint,
    );

    paint.color = isDark
        ? Colors.white.withValues(alpha: 0.025)
        : Colors.black.withValues(alpha: 0.025);

    canvas.drawCircle(
      center,
      size.width * 0.49,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}