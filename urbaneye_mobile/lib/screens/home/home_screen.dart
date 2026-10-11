
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  Map<String, dynamic> _profile = {};
  List<Map<String, dynamic>> _reports = [];

  bool _loading = true;
  bool _reportsError = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ============================================================
  // LOAD PROFILE AND REPORTS FROM DJANGO
  // ============================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _reportsError = false;
      });
    }

    // Load profile independently so a profile error does not
    // prevent the reports list from loading.
    try {
      final profile = await ApiClient.getProfile();

      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (_) {
      // Keep the fallback greeting if the profile request fails.
    }

    try {
      final reports = await ApiClient.getReports();

      if (mounted) {
        setState(() {
          _reports = reports;
          _reportsError = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _reportsError = true);
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // ============================================================
  // USER DATA
  // ============================================================

  String get _userName {
    final firstName =
        (_profile['first_name'] ?? '').toString().trim();
    final lastName =
        (_profile['last_name'] ?? '').toString().trim();
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;

    final username =
        (_profile['username'] ?? '').toString().trim();

    if (username.isNotEmpty) return username;

    return 'Ahad';
  }

  String get _avatarLetter {
    final name = _userName.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : 'A';
  }

  // ============================================================
  // REPORT DATA HELPERS
  // ============================================================

  String _reportType(Map<String, dynamic> report) {
    final value = report['issue_type'] ??
        report['issueType'] ??
        report['title'] ??
        'Civic issue';

    return value.toString().replaceAll('_', ' ').split(' ').map(
      (word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
      },
    ).join(' ');
  }

  String _reportStatus(Map<String, dynamic> report) {
    return (report['status'] ?? 'pending')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ');
  }

  String _reportLocation(Map<String, dynamic> report) {
    final location = report['location'] ??
        report['address'] ??
        report['location_name'];

    if (location == null || location.toString().trim().isEmpty) {
      return 'Location not available';
    }

    return location.toString();
  }

  String _displayStatus(Map<String, dynamic> report) {
    final status = _reportStatus(report);

    if (status == 'resolved') return 'Resolved';
    if (status == 'pending') return 'Pending';

    if (status.isEmpty) return 'Pending';

    return status.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  int get _totalReports => _reports.length;

  int get _resolvedReports => _reports.where((report) {
        return _reportStatus(report) == 'resolved';
      }).length;

  int get _pendingReports => _reports.where((report) {
        final status = _reportStatus(report);
        return status == 'pending' ||
            status == 'submitted' ||
            status == 'reviewing' ||
            status == 'under review';
      }).length;

  IconData _reportIcon(Map<String, dynamic> report) {
    final type = _reportType(report).toLowerCase();

    if (type.contains('pothole')) {
      return Icons.warning_amber_rounded;
    }

    if (type.contains('garbage')) {
      return Icons.delete_outline_rounded;
    }

    if (type.contains('street light')) {
      return Icons.lightbulb_outline_rounded;
    }

    if (type.contains('water')) {
      return Icons.water_drop_outlined;
    }

    if (type.contains('crack')) {
      return Icons.construction_rounded;
    }

    return Icons.report_problem_outlined;
  }

  // ============================================================
  // THEME
  // ============================================================

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      Theme.of(context).scaffoldBackgroundColor;

  Color get primaryText =>
      Theme.of(context).colorScheme.onSurface;

  Color get secondaryText => isDark
      ? const Color(0xFFB0B0B8)
      : const Color(0xFF6B6675);

  Color get cardColor =>
      isDark ? const Color(0xD91C1C1E) : Colors.white;

  Color get cardBorder => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  Color get badgeBackground => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.045);

  Color get actionIcon => isDark
      ? Colors.white.withValues(alpha: 0.75)
      : Colors.black.withValues(alpha: 0.60);

  Color get mutedIcon => isDark
      ? Colors.white.withValues(alpha: 0.45)
      : Colors.black.withValues(alpha: 0.40);

  Color get topGlow =>
      isDark ? const Color(0xFF6E3BA7) : const Color(0xFFE9D5FF);

  Color get midGlow =>
      isDark ? const Color(0xFF2B1446) : const Color(0xFFF3E8FF);

  Color get lowerAmbient =>
      isDark ? const Color(0xFF0D0B12) : const Color(0xFFF8F7FC);

  Color get bottomBackground =>
      isDark ? Colors.black : const Color(0xFFF8F7FC);

  Color get profileAvatar =>
      isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0ECF5);

  Color get accentColor =>
      isDark ? const Color(0xFFB78BEA) : const Color(0xFF6D28D9);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      extendBody: true,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.20, 0.46, 0.68, 1.0],
                  colors: [
                    topGlow,
                    midGlow,
                    lowerAmbient,
                    bottomBackground,
                    bottomBackground,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -130,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: topGlow.withValues(
                        alpha: isDark ? 0.38 : 0.20,
                      ),
                      blurRadius: 110,
                      spreadRadius: 35,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadDashboard,
              color: accentColor,
              backgroundColor: cardColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 105),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 52),
                    _buildGreeting(),
                    const SizedBox(height: 30),
                    _buildModelBadge(),
                    const SizedBox(height: 22),
                    _buildSuggestionGrid(),
                    const SizedBox(height: 28),
                    _buildActivityCard(),
                    const SizedBox(height: 28),
                    _buildRecentReports(),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0D0B12)
          : const Color(0xFFF8F7FC),
      width: MediaQuery.of(context).size.width * 0.78,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF2C1A42)
                          : const Color(0xFFEDE9FE),
                      border: Border.all(color: cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: topGlow.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _avatarLetter,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF5B21B6),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          (_profile['email'] ?? 'UrbanEye User').toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: secondaryText,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: cardBorder, height: 1),
            ),
            const SizedBox(height: 14),
            _drawerItem(
              icon: Icons.home_outlined,
              title: 'Home',
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
                context.go('/home');
              },
            ),
            _drawerItem(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
            ),
            _drawerItem(
              icon: Icons.description_outlined,
              title: 'My Reports',
              onTap: () {
                Navigator.of(context).pop();
                context.go('/reports');
              },
            ),
            _drawerItem(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/notifications');
              },
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: cardBorder, height: 1),
            ),
            const SizedBox(height: 18),
            _drawerItem(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                Navigator.of(context).pop();
                _showMessage('Help & Support will be available soon.');
              },
            ),
            _drawerItem(
              icon: Icons.info_outline_rounded,
              title: 'About UrbanEye',
              onTap: () {
                Navigator.of(context).pop();
                _showAboutDialog();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: _drawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                danger: true,
                onTap: () {
                  Navigator.of(context).pop();
                  _showLogoutDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
    bool danger = false,
  }) {
    final iconColor = danger
        ? const Color(0xFFE57373)
        : selected
            ? accentColor
            : secondaryText;

    final textColor =
        danger ? const Color(0xFFE57373) : primaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? (isDark
                ? const Color(0xFF21152D)
                : const Color(0xFFEDE9FE))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? badgeBackground : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: iconColor,
                    size: 19,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT AND ABOUT
  // ============================================================

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF18151D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from UrbanEye?',
          style: TextStyle(color: secondaryText, height: 1.45),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: TextStyle(color: secondaryText)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ApiClient.logout();
              } catch (_) {
                // Still return to login if local logout encounters an error.
              }

              if (!mounted) return;
              context.go('/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFE57373),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF18151D) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C1A42)
                    : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: accentColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'UrbanEye',
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'AI-Based Image Analysis System for Automated '
          'Civic Issue Detection and Severity Assessment.\n\n'
          'Version 1.0.0',
          style: TextStyle(color: secondaryText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Close', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xFF242126) : const Color(0xFF2D2438),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconButton(
          icon: Icons.menu_rounded,
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        Column(
          children: [
            Text(
              'URBANEYE',
              style: TextStyle(
                color: primaryText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.8,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: primaryText.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: profileAvatar,
              shape: BoxShape.circle,
              border: Border.all(color: cardBorder),
            ),
            child: Center(
              child: Text(
                _avatarLetter,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GREETING
  // ============================================================

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $_userName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: primaryText,
            fontSize: 31,
            height: 1.1,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'May I help you?',
          style: TextStyle(
            color: primaryText.withValues(alpha: isDark ? 0.92 : 0.88),
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Analyze a civic issue or explore your reports.',
          style: TextStyle(
            color: secondaryText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MODEL BADGE
  // ============================================================

  Widget _buildModelBadge() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: badgeBackground,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: primaryText,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'UrbanEye AI',
          style: TextStyle(
            color: primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 7),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: primaryText,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'Detection assistant',
          style: TextStyle(
            color: primaryText.withValues(alpha: 0.60),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUGGESTION GRID
  // ============================================================

  Widget _buildSuggestionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _bentoCard(
                icon: Icons.auto_awesome_outlined,
                title: 'AI Detection',
                subtitle: 'Identify civic issues',
                onTap: () => context.push('/capture'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bentoCard(
                icon: Icons.description_outlined,
                title: 'My Reports',
                subtitle: 'View submitted reports',
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _bentoCard(
                icon: Icons.location_on_outlined,
                title: 'Nearby Issues',
                subtitle: 'Explore reported problems',
                onTap: () => context.go('/reports'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _bentoCard(
                icon: Icons.insights_outlined,
                title: 'Insights',
                subtitle: 'Track your civic activity',
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bentoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 148,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: actionIcon, size: 19),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryText,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY - LIVE DATABASE COUNTS
  // ============================================================

  Widget _buildActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your activity',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/reports'),
                child: Text(
                  'View all',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading && _reports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_reportsError && _reports.isEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Could not load report statistics.',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadDashboard,
                  child: Text('Retry', style: TextStyle(color: accentColor)),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _activityItem(
                    value: '$_totalReports',
                    label: 'Reports',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _activityItem(
                    value: '$_resolvedReports',
                    label: 'Resolved',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _activityItem(
                    value: '$_pendingReports',
                    label: 'Pending',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _activityItem({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: primaryText,
            fontSize: 23,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: cardBorder,
    );
  }

  // ============================================================
  // RECENT REPORTS - LIVE DATABASE DATA
  // ============================================================

  Widget _buildRecentReports() {
    final recentReports = _reports.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent reports',
              style: TextStyle(
                color: primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/reports'),
              child: Text(
                'See all',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_loading && _reports.isEmpty)
          _buildInfoCard(
            icon: Icons.sync_rounded,
            message: 'Loading your reports...',
          )
        else if (_reportsError && _reports.isEmpty)
          _buildRetryCard()
        else if (recentReports.isEmpty)
          _buildInfoCard(
            icon: Icons.description_outlined,
            message: 'No reports yet. Capture an image to get started.',
          )
        else
          ...recentReports.map((report) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _reportItem(
                report: report,
                icon: _reportIcon(report),
                title: _reportType(report),
                location: _reportLocation(report),
                status: _displayStatus(report),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: secondaryText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: secondaryText,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Unable to load reports from the server.',
              style: TextStyle(color: secondaryText, fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: _loadDashboard,
            child: Text('Retry', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _reportItem({
    required Map<String, dynamic> report,
    required IconData icon,
    required String title,
    required String location,
    required String status,
  }) {
    return GestureDetector(
      onTap: () {
        final id = report['id'] ?? report['pk'];

        if (id != null) {
          context.push('/report-details', extra: report);
        } else {
          context.go('/reports');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: actionIcon, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: mutedIcon,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _statusBadge(status),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    final Color statusColor = normalized == 'resolved'
        ? const Color(0xFF62C994)
        : normalized == 'pending' || normalized == 'submitted'
            ? const Color(0xFFE7B766)
            : secondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101012).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.10),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          _navItem(
            index: 1,
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
            label: 'Reports',
          ),
          _captureNavItem(),
          _navItem(
            index: 3,
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            label: 'Alerts',
          ),
          _navItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 21,
              color: selected
                  ? primaryText
                  : primaryText.withValues(alpha: 0.42),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? primaryText
                    : primaryText.withValues(alpha: 0.42),
                fontSize: 8.5,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _captureNavItem() {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = 2);
        context.push('/capture');
      },
      child: Container(
        width: 49,
        height: 49,
        decoration: BoxDecoration(
          color: isDark ? midGlow : const Color(0xFFE9D5FF),
          shape: BoxShape.circle,
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: topGlow.withValues(alpha: isDark ? 0.24 : 0.20),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.camera_alt_outlined,
          color: isDark ? Colors.white : const Color(0xFF5B21B6),
          size: 21,
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: badgeBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardBorder),
          ),
          child: Icon(icon, color: primaryText, size: 21),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/reports');
        break;
      case 2:
        context.push('/capture');
        break;
      case 3:
        context.push('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}
