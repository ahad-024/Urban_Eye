import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AiResultScreen extends StatefulWidget {
  final XFile image;

  const AiResultScreen({
    super.key,
    required this.image,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  // ============================================================
  // URBANEYE COLORS
  // ============================================================

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);

  // ============================================================
  // AI RESULT STATE
  // ============================================================

  Uint8List? _imageBytes;
  bool _isLoading = true;

  // Mock AI result for UI.
  // Real YOLO/API result will be connected later.
  final String _issueType = 'Pothole';
  final String _severity = 'High';
  final int _confidence = 96;
  final int _severityScore = 86;

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

  Color _mutedText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF77777F)
        : const Color(0xFF8A8592);
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF1C1C1E)
        : Colors.white;
  }

  Color _cardSoftColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFF151517)
        : const Color(0xFFF3F0F7);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _subtleColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.035)
        : Colors.black.withValues(alpha: 0.035);
  }

  Color _progressBackground(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.07);
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _reportIssue() {
    context.push(
      '/submit-complaint',
      extra: {
        'image': widget.image,
        'issueType': _issueType,
        'severity': _severity,
        'confidence': _confidence,
      },
    );
  }

  void _analyzeAnother() {
    context.go('/capture');
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/capture');
    }
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: Stack(
        children: [
          _buildBackground(context),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),

                        const SizedBox(height: 24),

                        _buildImagePreview(context),

                        const SizedBox(height: 20),

                        _buildIssueCard(context),

                        const SizedBox(height: 16),

                        _buildQuickStats(context),

                        const SizedBox(height: 20),

                        _buildAiAnalysisCard(context),

                        const SizedBox(height: 16),

                        _buildSeverityCard(context),

                        const SizedBox(height: 16),

                        _buildConfidenceCard(context),

                        const SizedBox(height: 16),

                        _buildRecommendedAction(context),

                        const SizedBox(height: 26),

                        _buildActionButtons(context),

                        const SizedBox(height: 18),

                        _buildSecurityNote(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  Widget _buildBackground(BuildContext context) {
    final bool isDark = _isDark(context);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -180,
            left: -100,
            right: -100,
            child: Container(
              height: 420,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          purple.withValues(alpha: 0.30),
                          const Color(0xFF32145C).withValues(alpha: 0.16),
                          Colors.transparent,
                        ]
                      : [
                          purple.withValues(alpha: 0.16),
                          const Color(0xFFE7D4FA)
                              .withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 360,
            right: -180,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    purple.withValues(
                      alpha: isDark ? 0.08 : 0.045,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Colors.transparent,
                          Color(0x33000000),
                          Color(0xFF000000),
                        ]
                      : [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.65),
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          _circleButton(
            context: context,
            icon: Icons.arrow_back_rounded,
            onTap: _goBack,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              'AI Result',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: success.withValues(alpha: 0.18),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: success,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'Complete',
                  style: TextStyle(
                    color: success,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _cardColor(context).withValues(
              alpha: _isDark(context) ? 0.88 : 0.90,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 21,
          ),
        ),
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
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: purple.withValues(alpha: 0.22),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: purpleLight,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'ANALYSIS COMPLETE',
                style: TextStyle(
                  color: purpleLight,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Civic issue detected',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 30,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'UrbanEye AI has analyzed your image and identified a potential civic issue.',
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 14,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE PREVIEW
  // ============================================================

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: purpleLight,
                    ),
                  )
                : _imageBytes != null
                    ? Image.memory(
                        _imageBytes!,
                        fit: BoxFit.cover,
                      )
                    : _imagePlaceholder(context),
          ),

          // Keep image readable while preserving bottom text contrast.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.80),
                  ],
                  stops: const [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 14,
            left: 14,
            child: _imageBadge(
              icon: Icons.image_outlined,
              text: 'IMAGE READY',
            ),
          ),

          Positioned(
            top: 14,
            right: 14,
            child: _imageBadge(
              icon: Icons.auto_awesome_rounded,
              text: 'AI ANALYZED',
            ),
          ),

          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_issueType detected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: success.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: success,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDark(context)
              ? const [
                  Color(0xFF20152D),
                  Color(0xFF111113),
                ]
              : const [
                  Color(0xFFF0E7F7),
                  Color(0xFFF8F7FC),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: _mutedText(context),
          size: 52,
        ),
      ),
    );
  }

  Widget _imageBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.shrink(),
          Icon(
            icon,
            color: purpleLight,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ISSUE CARD
  // ============================================================

  Widget _buildIssueCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context).withValues(
          alpha: _isDark(context) ? 0.90 : 0.96,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: warning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: warning,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detected Issue',
                  style: TextStyle(
                    color: _mutedText(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _issueType,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: success.withValues(alpha: 0.16),
              ),
            ),
            child: const Text(
              'Detected',
              style: TextStyle(
                color: success,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK STATS
  // ============================================================

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            context: context,
            icon: Icons.category_outlined,
            label: 'Issue',
            value: _issueType,
            iconColor: purpleLight,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _statCard(
            context: context,
            icon: Icons.priority_high_rounded,
            label: 'Severity',
            value: _severity,
            iconColor: warning,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _statCard(
            context: context,
            icon: Icons.analytics_outlined,
            label: 'Confidence',
            value: '$_confidence%',
            iconColor: success,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 13),
      decoration: BoxDecoration(
        color: _cardSoftColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 19,
          ),

          const SizedBox(height: 13),

          Text(
            label,
            style: TextStyle(
              color: _mutedText(context),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AI ANALYSIS CARD
  // ============================================================

  Widget _buildAiAnalysisCard(BuildContext context) {
    return _sectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context: context,
            icon: Icons.auto_awesome_rounded,
            title: 'AI Analysis',
          ),

          const SizedBox(height: 18),

          Text(
            'UrbanEye AI identified a pothole in the submitted image. '
            'The damaged road surface appears significant enough to '
            'potentially affect vehicle movement and pedestrian safety.',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 13,
              height: 1.65,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _subtleColor(context),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.memory_rounded,
                  color: purpleLight,
                  size: 19,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Classification: Civic Infrastructure Damage',
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context).withValues(
          alpha: _isDark(context) ? 0.88 : 0.96,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: purpleLight,
            size: 17,
          ),
        ),

        const SizedBox(width: 11),

        Text(
          title,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEVERITY CARD
  // ============================================================

  Widget _buildSeverityCard(BuildContext context) {
    final double progress = _severityScore / 100;

    return _sectionCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            context: context,
            icon: Icons.speed_rounded,
            title: 'Severity Assessment',
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'High',
                style: TextStyle(
                  color: warning,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(width: 9),

              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'severity',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 12,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '$_severityScore/100',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: _progressBackground(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                warning,
              ),
            ),
          ),

          const SizedBox(height: 11),

          Text(
            'The detected issue requires attention and should be reported to the relevant civic authority.',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIDENCE CARD
  // ============================================================

  Widget _buildConfidenceCard(BuildContext context) {
    return _sectionCard(
      context: context,
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: _confidence / 100,
                    strokeWidth: 7,
                    backgroundColor: _progressBackground(context),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(success),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_confidence%',
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    Text(
                      'AI',
                      style: TextStyle(
                        color: _mutedText(context),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Confidence',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'The AI model is highly confident in this classification.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: success,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'High confidence',
                      style: TextStyle(
                        color: success,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECOMMENDED ACTION
  // ============================================================

  Widget _buildRecommendedAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            purple.withValues(
              alpha: _isDark(context) ? 0.16 : 0.10,
            ),
            purple.withValues(
              alpha: _isDark(context) ? 0.05 : 0.035,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withValues(
            alpha: _isDark(context) ? 0.18 : 0.14,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: purpleLight,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Action',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Submit a civic complaint so the issue can be reviewed and addressed by the relevant authority.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 57,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFF6D28D9),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: purple.withValues(alpha: 0.28),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _reportIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 20,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Report This Issue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _analyzeAnother,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryText(context),
              backgroundColor: _cardSoftColor(context),
              side: BorderSide(
                color: _borderColor(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 19,
                ),
                SizedBox(width: 9),
                Text(
                  'Analyze Another Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECURITY NOTE
  // ============================================================

  Widget _buildSecurityNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _subtleColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: _mutedText(context),
            size: 16,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              'AI analysis is currently running in UI demo mode. '
              'Real model integration will be connected later.',
              style: TextStyle(
                color: _mutedText(context),
                fontSize: 10,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}