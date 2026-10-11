import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AiLoadingScreen extends StatefulWidget {
  final XFile image;

  const AiLoadingScreen({
    super.key,
    required this.image,
  });

  @override
  State<AiLoadingScreen> createState() => _AiLoadingScreenState();
}

class _AiLoadingScreenState extends State<AiLoadingScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // URBANEYE COLORS
  // ============================================================

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);

  // ============================================================
  // ANIMATION / ANALYSIS STATE
  // ============================================================

  late final AnimationController _animationController;

  Timer? _timer;

  double _progress = 0.0;

  int _currentStep = 0;

  bool _isCompleting = false;

  final List<String> _steps = const [
    'Preparing image',
    'Detecting civic issue',
    'Assessing severity',
    'Calculating confidence',
    'Finalizing analysis',
  ];

  // ============================================================
  // THEME HELPERS
  // ============================================================

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
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6B6675);
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xE61C1C1E)
        : Colors.white;
  }

  Color _softCardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0x991C1C1E)
        : const Color(0xFFF3F0F7);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _subtleBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.035);
  }

  Color _mutedColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.35);
  }

  Color _progressTrackColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _startAnalysis();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // AI ANALYSIS SIMULATION
  // ============================================================

  void _startAnalysis() {
    const int totalMilliseconds = 6000;
    const int intervalMilliseconds = 100;

    int elapsedMilliseconds = 0;

    _timer = Timer.periodic(
      const Duration(milliseconds: intervalMilliseconds),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        elapsedMilliseconds += intervalMilliseconds;

        final progress =
            (elapsedMilliseconds / totalMilliseconds).clamp(0.0, 1.0);

        int step;

        if (progress < 0.20) {
          step = 0;
        } else if (progress < 0.40) {
          step = 1;
        } else if (progress < 0.60) {
          step = 2;
        } else if (progress < 0.80) {
          step = 3;
        } else {
          step = 4;
        }

        setState(() {
          _progress = progress;
          _currentStep = step;
        });

        if (elapsedMilliseconds >= totalMilliseconds) {
          timer.cancel();
          _completeAnalysis();
        }
      },
    );
  }

  Future<void> _completeAnalysis() async {
    if (_isCompleting || !mounted) return;

    setState(() {
      _isCompleting = true;
      _progress = 1.0;
      _currentStep = _steps.length - 1;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    context.go(
      '/ai-result',
      extra: widget.image,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String get _percentage {
    return '${(_progress * 100).round()}%';
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark = _isDark(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _backgroundColor(context),
        body: Stack(
          children: [
            _AiBackground(
              isDark: isDark,
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(context),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        10,
                        20,
                        28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusBadge(context),

                          const SizedBox(height: 22),

                          _buildHeader(context),

                          const SizedBox(height: 28),

                          _buildAiAnimation(context),

                          const SizedBox(height: 30),

                          _buildProgressCard(context),

                          const SizedBox(height: 18),

                          _buildAnalysisSteps(context),

                          const SizedBox(height: 18),

                          _buildPrivacyNote(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    final bool isDark = _isDark(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        8,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0x661C1C1E)
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _borderColor(context),
              ),
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              color: _primaryText(context),
              size: 20,
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'URBANEYE',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
            ),
          ),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : Colors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
              border: Border.all(
                color: _borderColor(context),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'A',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: _isDark(context)
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            color: purpleLight,
            size: 8,
          ),
          const SizedBox(width: 8),
          Text(
            'URBANEYE AI',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyzing your image',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'UrbanEye AI is carefully examining the image '
          'to identify civic issues and assess their severity.',
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AI ANIMATION
  // ============================================================

  Widget _buildAiAnimation(BuildContext context) {
    final bool isDark = _isDark(context);

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _animationController.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(210, 210),
                    painter: _OrbitRingPainter(
                      color: purpleLight,
                      opacity: isDark ? 0.35 : 0.42,
                      strokeWidth: 1.2,
                      dashCount: 36,
                    ),
                  ),
                ),

                Transform.rotate(
                  angle: -_animationController.value * math.pi * 2,
                  child: CustomPaint(
                    size: const Size(170, 170),
                    painter: _OrbitRingPainter(
                      color: purple,
                      opacity: isDark ? 0.55 : 0.48,
                      strokeWidth: 1.0,
                      dashCount: 28,
                    ),
                  ),
                ),

                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xD91C1C1E)
                        : Colors.white.withValues(alpha: 0.92),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.16)
                          : Colors.black.withValues(alpha: 0.07),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withValues(
                          alpha: isDark ? 0.22 : 0.18,
                        ),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: _primaryText(context),
                    size: 38,
                  ),
                ),

                Positioned(
                  top: 25,
                  right: 34,
                  child: _buildOrbitDot(7),
                ),

                Positioned(
                  bottom: 29,
                  left: 30,
                  child: _buildOrbitDot(5),
                ),

                Positioned(
                  top: 84,
                  left: 11,
                  child: _buildOrbitDot(4),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrbitDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: purpleLight,
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.55),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Analysis progress',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _percentage,
                style: const TextStyle(
                  color: purpleLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 7,
              color: _progressTrackColor(context),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          purple,
                          purpleLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _steps[_currentStep],
              key: ValueKey(_currentStep),
              style: TextStyle(
                color: _secondaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ANALYSIS STEPS
  // ============================================================

  Widget _buildAnalysisSteps(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI analysis',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...List.generate(
            _steps.length,
            (index) {
              return _buildStep(
                context: context,
                index: index,
                title: _steps[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required int index,
    required String title,
  }) {
    final bool completed = index < _currentStep;
    final bool active = index == _currentStep;

    final Color inactiveText = _mutedColor(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: index == _steps.length - 1 ? 0 : 14,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed
                  ? purple.withValues(alpha: 0.20)
                  : active
                      ? _subtleBackground(context)
                      : _isDark(context)
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.035),
              border: Border.all(
                color: completed || active
                    ? purpleLight.withValues(alpha: 0.55)
                    : _borderColor(context),
              ),
            ),
            child: Icon(
              completed
                  ? Icons.check_rounded
                  : active
                      ? Icons.more_horiz_rounded
                      : Icons.circle_outlined,
              size: completed ? 17 : 15,
              color: completed || active
                  ? _primaryText(context)
                  : inactiveText,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: completed || active
                    ? _primaryText(context)
                    : inactiveText,
                fontSize: 13,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),

          if (completed)
            const Icon(
              Icons.check_rounded,
              color: purpleLight,
              size: 18,
            )
          else if (active)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor: AlwaysStoppedAnimation<Color>(
                  purpleLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVACY NOTE
  // ============================================================

  Widget _buildPrivacyNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _softCardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: _mutedColor(context),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your image is being processed securely. '
              'AI analysis will complete automatically.',
              style: TextStyle(
                color: _secondaryText(context).withValues(
                  alpha: _isDark(context) ? 0.72 : 0.82,
                ),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BACKGROUND
// ============================================================

class _AiBackground extends StatelessWidget {
  final bool isDark;

  const _AiBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.0,
              0.25,
              0.55,
              1.0,
            ],
            colors: isDark
                ? const [
                    Color(0xFF6E3BA7),
                    Color(0xFF2B1446),
                    Color(0xFF0D0B12),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFE7D4FA),
                    Color(0xFFF1E7F8),
                    Color(0xFFF8F7FC),
                    Color(0xFFFFFFFF),
                  ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ORBIT RING PAINTER
// ============================================================

class _OrbitRingPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;
  final int dashCount;

  const _OrbitRingPainter({
    required this.color,
    required this.opacity,
    required this.strokeWidth,
    required this.dashCount,
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

    final radius =
        math.min(size.width, size.height) / 2 - 5;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final dashAngle = (math.pi * 2) / dashCount;

    const double gapFactor = 0.55;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        dashAngle * gapFactor,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _OrbitRingPainter oldDelegate,
  ) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashCount != dashCount;
  }
}