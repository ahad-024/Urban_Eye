import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ComplaintSuccessScreen extends StatelessWidget {
  final String issueType;
  final String severity;

  const ComplaintSuccessScreen({
    super.key,
    required this.issueType,
    required this.severity,
  });

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color success = Color(0xFF63D39A);
  static const Color warning = Color(0xFFF2B94B);
  static const Color danger = Color(0xFFFF6B6B);

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
        : const Color(0xFF68636F);
  }

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0xD91C1C1E)
        : Colors.white.withValues(alpha: 0.94);
  }

  Color _cardSoftColor(BuildContext context) {
    return _isDark(context)
        ? const Color(0x991C1C1E)
        : const Color(0xFFF3F0F7);
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _severityColor() {
    switch (severity.toLowerCase()) {
      case 'high':
        return danger;
      case 'medium':
        return warning;
      case 'low':
        return success;
      default:
        return purpleLight;
    }
  }

  String _severityDescription() {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'Requires prompt attention';
      case 'medium':
        return 'Needs municipal attention';
      case 'low':
        return 'Lower priority issue';
      default:
        return 'Issue severity assessed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor();

    return Scaffold(
      backgroundColor: _backgroundColor(context),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _SuccessBackground(
                isDark: _isDark(context),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _topButton(
                        context,
                        icon: LucideIcons.x,
                        onTap: () {
                          context.go('/home');
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'URBANEYE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _primaryText(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'REPORT STATUS',
                              style: TextStyle(
                                color: _secondaryText(context),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 46),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 30),
                    child: Column(
                      children: [
                        _successHero(context),
                        const SizedBox(height: 18),
                        _reportSummary(context, severityColor),
                        const SizedBox(height: 14),
                        _trackingCard(context),
                        const SizedBox(height: 22),
                        _viewReportsButton(context),
                        const SizedBox(height: 10),
                        _homeButton(context),
                        const SizedBox(height: 18),
                        Text(
                          'Thank you for helping improve your community.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _successHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _borderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(
              alpha: _isDark(context) ? 0.12 : 0.08,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: purpleLight.withValues(alpha: 0.20),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: purpleLight.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(
                LucideIcons.check,
                color: _isDark(context) ? purpleLight : purple,
                size: 43,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Complaint Submitted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your civic issue has been successfully '
            'recorded and is ready to be tracked.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 12.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: success.withValues(alpha: 0.16),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  color: success,
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'REPORT RECORDED',
                  style: TextStyle(
                    color: success,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportSummary(
    BuildContext context,
    Color severityColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.fileCheck2,
                color: _isDark(context) ? purpleLight : purple,
                size: 19,
              ),
              const SizedBox(width: 9),
              Text(
                'Report Summary',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryRow(
            icon: LucideIcons.alertTriangle,
            label: 'Issue Type',
            value: issueType,
            primaryText: _primaryText(context),
            secondaryText: _secondaryText(context),
            iconColor: _isDark(context) ? purpleLight : purple,
            iconBackground: purple.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 13),
          Container(
            height: 1,
            color: _borderColor(context),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: severityColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  LucideIcons.alertTriangle,
                  color: severityColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Severity',
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _severityDescription(),
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trackingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSoftColor(context),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.activity,
              color: _isDark(context) ? purpleLight : purple,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track your complaint',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You can monitor the status of this report '
                  'anytime from My Reports.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewReportsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          context.go('/reports');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.folderOpen,
              size: 18,
            ),
            SizedBox(width: 9),
            Text(
              'View My Reports',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          context.go('/home');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText(context),
          backgroundColor: _cardColor(context),
          side: BorderSide(
            color: _borderColor(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.home,
              size: 17,
              color: _primaryText(context),
            ),
            const SizedBox(width: 8),
            Text(
              'Back to Home',
              style: TextStyle(
                color: _primaryText(context),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _cardColor(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _SuccessBackground extends StatelessWidget {
  final bool isDark;

  const _SuccessBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -170,
              left: -120,
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB78BEA).withValues(alpha: 0.24),
                      const Color(0xFFB78BEA).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF1E5FA),
                      Color(0xFFF8F7FC),
                      Color(0xFFFFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -170,
            left: -120,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6E3BA7).withValues(alpha: 0.34),
                    const Color(0xFF6E3BA7).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            right: -180,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.10),
                    const Color(0xFF7C3AED).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D0B12),
                    Color(0xFF08080A),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color primaryText;
  final Color secondaryText;
  final Color iconColor;
  final Color iconBackground;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.primaryText,
    required this.secondaryText,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}