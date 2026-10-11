import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Spot Civic Issues',
      description:
          'Capture a photo of a civic problem and let UrbanEye identify it for you.',
      icon: LucideIcons.scanLine,
      badge: 'AI VISION',
    ),
    _OnboardingData(
      title: 'AI-Powered Analysis',
      description:
          'Our intelligent system detects the issue type and estimates its severity automatically.',
      icon: LucideIcons.sparkles,
      badge: 'SMART ANALYSIS',
    ),
    _OnboardingData(
      title: 'Report With Confidence',
      description:
          'Submit accurate complaints with your location and AI-generated issue details.',
      icon: LucideIcons.mapPin,
      badge: 'SMART REPORTING',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _backgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFB0ADB7)
        : const Color(0xFF6B6675);
  }

  Color _softCard(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF141218)
        : Colors.white;
  }

  Color _softBorder(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _pages.length) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  void _onPageChanged(int index) {
    if (!mounted) return;

    setState(() {
      _currentPage = index;
    });

    _fadeController
      ..reset()
      ..forward();

    _scaleController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -size.height * 0.10,
            right: -size.width * 0.20,
            child: IgnorePointer(
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(
                        alpha: isDark ? 0.22 : 0.12,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -size.height * 0.08,
            left: -size.width * 0.30,
            child: IgnorePointer(
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB78BEA).withValues(
                        alpha: isDark ? 0.10 : 0.08,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFF6D28D9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(
                                alpha: isDark ? 0.35 : 0.20,
                              ),
                              blurRadius: 18,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.scanLine,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Text(
                        'UrbanEye',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          foregroundColor: _secondaryText(context),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final page = _pages[index];

                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _fadeController,
                          _scaleController,
                        ]),
                        builder: (context, child) {
                          final fadeValue = CurvedAnimation(
                            parent: _fadeController,
                            curve: Curves.easeOut,
                          ).value;

                          final scaleValue =
                              0.94 + (_scaleController.value * 0.06);

                          return Opacity(
                            opacity: fadeValue.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: scaleValue,
                              child: child,
                            ),
                          );
                        },
                        child: _buildPage(
                          context,
                          page,
                          size,
                          index,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) {
                            final selected = index == _currentPage;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              width: selected ? 26 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: selected
                                    ? const Color(0xFF8B5CF6)
                                    : (_isDark(context)
                                        ? Colors.white.withValues(alpha: 0.16)
                                        : Colors.black.withValues(alpha: 0.12)),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFF6D28D9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(
                                  alpha: isDark ? 0.30 : 0.20,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Get Started'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  _currentPage == _pages.length - 1
                                      ? LucideIcons.arrowRight
                                      : LucideIcons.chevronRight,
                                  size: 19,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    _OnboardingData page,
    Size size,
    int index,
  ) {
    final isDark = _isDark(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withValues(
                  alpha: isDark ? 0.20 : 0.15,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  color: Color(0xFF9F7AEA),
                  size: 14,
                ),
                const SizedBox(width: 7),
                Text(
                  page.badge,
                  style: const TextStyle(
                    color: Color(0xFF9F7AEA),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Illustration
          Container(
            width: size.width * 0.67,
            height: size.width * 0.67,
            constraints: const BoxConstraints(
              maxWidth: 285,
              maxHeight: 285,
              minWidth: 220,
              minHeight: 220,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withValues(
                    alpha: isDark ? 0.20 : 0.11,
                  ),
                  const Color(0xFF7C3AED).withValues(
                    alpha: isDark ? 0.06 : 0.04,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: size.width * 0.54,
                  height: size.width * 0.54,
                  constraints: const BoxConstraints(
                    maxWidth: 230,
                    maxHeight: 230,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(
                        alpha: isDark ? 0.18 : 0.13,
                      ),
                      width: 1,
                    ),
                  ),
                ),

                // Inner card
                Container(
                  width: size.width * 0.40,
                  height: size.width * 0.40,
                  constraints: const BoxConstraints(
                    maxWidth: 170,
                    maxHeight: 170,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(38),
                    color: _softCard(context),
                    border: Border.all(
                      color: _softBorder(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(
                          alpha: isDark ? 0.18 : 0.10,
                        ),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFF6D28D9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(
                                alpha: isDark ? 0.35 : 0.20,
                              ),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: Icon(
                          page.icon,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),

                      // Small decorative dots
                      Positioned(
                        top: 20,
                        right: 25,
                        child: _glowDot(
                          isDark
                              ? Colors.white.withValues(alpha: 0.65)
                              : const Color(0xFF7C3AED),
                          5,
                        ),
                      ),

                      Positioned(
                        bottom: 24,
                        left: 23,
                        child: _glowDot(
                          const Color(0xFFB78BEA),
                          4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating AI sparkle
                Positioned(
                  top: 28,
                  right: 35,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _softCard(context),
                      border: Border.all(
                        color: _softBorder(context),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withValues(
                            alpha: isDark ? 0.18 : 0.10,
                          ),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      color: Color(0xFF9F7AEA),
                      size: 17,
                    ),
                  ),
                ),

                // Floating scan icon
                Positioned(
                  bottom: 32,
                  left: 30,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _softCard(context),
                      border: Border.all(
                        color: _softBorder(context),
                      ),
                    ),
                    child: Icon(
                      LucideIcons.scan,
                      color: _secondaryText(context),
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          // Page number
          Text(
            '0${index + 1} / 0${_pages.length}',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 31,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),

          const SizedBox(height: 14),

          // Description
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 360,
            ),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 14.5,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final String badge;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.badge,
  });
}