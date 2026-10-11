import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color success = Color(0xFF63D39A);

  int? expandedIndex;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get cardColor =>
      isDark ? const Color(0xD91C1C1E) : Colors.white;

  Color get primaryText =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryText => isDark
      ? const Color(0xFFB0B0B8)
      : const Color(0xFF6B6675);

  Color get border => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _HelpSupportBackground(),
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    children: [
                      _buildHero(),
                      const SizedBox(height: 25),
                      _sectionTitle('QUICK HELP'),
                      const SizedBox(height: 10),
                      _buildQuickHelp(),
                      const SizedBox(height: 25),
                      _sectionTitle('FREQUENTLY ASKED QUESTIONS'),
                      const SizedBox(height: 10),
                      _buildFaqCard(),
                      const SizedBox(height: 25),
                      _sectionTitle('NEED MORE HELP?'),
                      const SizedBox(height: 10),
                      _buildContactCard(),
                      const SizedBox(height: 28),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _topButton(
            LucideIcons.arrowLeft,
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/settings');
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Text(
                  'URBANEYE',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'HELP & SUPPORT',
                  style: TextStyle(
                    color: secondaryText,
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
    );
  }

  Widget _topButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: primaryText, size: 19),
        ),
      ),
    );
  }

  // HERO

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: isDark ? 0.10 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: purple.withValues(alpha: 0.22),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.headphones,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Find answers and learn how to use UrbanEye.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 10.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: secondaryText,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // QUICK HELP

  Widget _buildQuickHelp() {
    return _container([
      _quickHelpTile(
        icon: LucideIcons.camera,
        iconColor: purpleLight,
        title: 'Create a Report',
        subtitle: 'Capture an image and analyze the issue',
        onTap: () => context.push('/capture'),
      ),
      _divider(),
      _quickHelpTile(
        icon: LucideIcons.mapPin,
        iconColor: success,
        title: 'Set Your Location',
        subtitle: 'Use your location for accurate reporting',
        onTap: () => _showInfo(
          'Location',
          'UrbanEye can use your device location when you '
              'submit a civic issue report. Make sure location '
              'permissions are enabled in your device settings.',
        ),
      ),
      _divider(),
      _quickHelpTile(
        icon: LucideIcons.fileText,
        iconColor: purpleLight,
        title: 'View My Reports',
        subtitle: 'Track the reports you have submitted',
        onTap: () => context.push('/reports'),
      ),
    ]);
  }

  Widget _quickHelpTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          child: Row(
            children: [
              _iconBox(icon, iconColor),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 9.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: secondaryText,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FAQ

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How does UrbanEye detect civic issues?',
      'answer':
          'UrbanEye is designed to analyze submitted images, '
              'identify supported civic issue categories and estimate '
              'their severity. The current analysis flow may use demo '
              'results until the trained AI model is integrated.',
    },
    {
      'question': 'Which issues can UrbanEye detect?',
      'answer':
          'Supported categories include potholes, road cracks, '
              'garbage, street lights and water overflow.',
    },
    {
      'question': 'How do I submit a complaint?',
      'answer':
          'Capture or select an image, review the analysis result, '
              'continue to the complaint form, add the necessary '
              'details and submit your complaint.',
    },
    {
      'question': 'Why is my location important?',
      'answer':
          'Location helps identify where a civic issue was reported '
              'and makes the report more useful for follow-up. Allow '
              'location access when prompted if you want to use it.',
    },
    {
      'question': 'Can I view my previous reports?',
      'answer':
          'Yes. Open the Reports section to see your submitted '
              'reports and the status information provided by the server.',
    },
    {
      'question': 'What if the AI result is incorrect?',
      'answer':
          'Check that the issue is clearly visible and that the image '
              'is not blurry or too dark. AI model integration and '
              'prediction accuracy depend on the model connected to '
              'the application.',
    },
  ];

  Widget _buildFaqCard() {
    return _container(
      List.generate(_faqs.length, (index) {
        final faq = _faqs[index];
        final expanded = expandedIndex == index;

        return Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    expandedIndex = expanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(21),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: purple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          LucideIcons.helpCircle,
                          color: purpleLight,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faq['question']!,
                              style: TextStyle(
                                color: primaryText,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            if (expanded) ...[
                              const SizedBox(height: 9),
                              Text(
                                faq['answer']!,
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 10,
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        expanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        color: secondaryText,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index != _faqs.length - 1) _divider(),
          ],
        );
      }),
    );
  }

  // CONTACT SUPPORT

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(LucideIcons.messageCircle, purpleLight),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get help using UrbanEye.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showContactDialog,
              icon: const Icon(LucideIcons.mail, size: 17),
              label: const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    _showInfo(
      'Contact Support',
      'For assistance, contact your UrbanEye project team through '
          'your designated support channel. Direct email or backend '
          'support integration can be added later.',
    );
  }

  // DIALOGS

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: border),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: secondaryText,
              height: 1.5,
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: purpleLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // SHARED UI

  Widget _container(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 62, right: 16),
      child: Container(height: 1, color: border),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.08),
        ),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'URBANEYE',
          style: TextStyle(
            color: primaryText,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'AI-BASED CIVIC ISSUE DETECTION',
          style: TextStyle(
            color: secondaryText,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Version 1.0.0',
          style: TextStyle(color: secondaryText, fontSize: 9),
        ),
      ],
    );
  }
}

// BACKGROUND

class _HelpSupportBackground extends StatelessWidget {
  const _HelpSupportBackground();

  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.20, 0.52, 1.0],
            colors: dark
                ? const [
                    Color(0xFF6E3BA7),
                    Color(0xFF2B1446),
                    Color(0xFF0D0B12),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFEDE9FE),
                    Color(0xFFF5F3FF),
                    Color(0xFFF8F7FC),
                    Color(0xFFF8F7FC),
                  ],
          ),
        ),
      ),
    );
  }
}
