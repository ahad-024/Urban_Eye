import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api/api_client.dart';
import '../../models/profile_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color success = Color(0xFF63D39A);
  static const Color danger = Color(0xFFFF6B6B);

  List<Map<String, dynamic>> _reports = [];
  bool _reportsLoading = true;
  String? _reportsError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ProfileData.instance.loadProfile();
      _loadReportStats();
    });
  }

  // ============================================================
  // LOAD REAL REPORT STATISTICS
  // ============================================================

  Future<void> _loadReportStats() async {
    if (!mounted) return;

    setState(() {
      _reportsLoading = true;
      _reportsError = null;
    });

    try {
      final reports = await ApiClient.getReports();

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _reportsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _reportsLoading = false;
        _reportsError = 'Could not load report statistics.';
      });
    }
  }

  String _getStatus(Map<String, dynamic> report) {
    return (report['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  Color _primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6B6675);
  }

  Color _card(BuildContext context) {
    return _isDark(context) ? const Color(0xE61C1C1E) : Colors.white;
  }

  Color _softCard(BuildContext context) {
    return _isDark(context)
        ? const Color(0x991C1C1E)
        : const Color(0xFFF4F0F8);
  }

  Color _border(BuildContext context) {
    return _isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.07);
  }

  Color _iconBackground(BuildContext context) =>
      purple.withValues(alpha: _isDark(context) ? 0.10 : 0.08);

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProfileData.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: _background(context),
          body: SafeArea(
            child: Stack(
              children: [
                _ProfileBackground(isDark: _isDark(context)),
                Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await Future.wait([
                            _loadReportStats(),
                            ProfileData.instance.loadProfile(),
                          ]);
                        },
                        color: purpleLight,
                        backgroundColor: _card(context),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            18,
                            16,
                            110,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHero(context),
                              const SizedBox(height: 12),
                              _buildProfileLoadStatus(context),
                              const SizedBox(height: 18),
                              _buildStats(context),
                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                context,
                                'Account',
                                'Manage your UrbanEye account',
                              ),
                              const SizedBox(height: 12),

                              _buildMenuCard(
                                context,
                                icon: LucideIcons.user,
                                title: 'Edit Profile',
                                subtitle:
                                    'Update your personal information',
                                onTap: () => context.push('/edit-profile'),
                              ),
                              const SizedBox(height: 9),

                              _buildMenuCard(
                                context,
                                icon: LucideIcons.bell,
                                title: 'Notifications',
                                subtitle:
                                    'Manage your notification preferences',
                                onTap: () =>
                                    context.push('/notifications'),
                              ),
                              const SizedBox(height: 9),

                              _buildMenuCard(
                                context,
                                icon: LucideIcons.settings,
                                title: 'Settings',
                                subtitle: 'App preferences and privacy',
                                onTap: () => context.push('/settings'),
                              ),
                              const SizedBox(height: 28),

                              _buildSectionTitle(
                                context,
                                'Support',
                                'Need help with UrbanEye?',
                              ),
                              const SizedBox(height: 12),

                              _buildMenuCard(
                                context,
                                icon: LucideIcons.helpCircle,
                                title: 'Help & Support',
                                subtitle: 'Get help with UrbanEye',
                                onTap: () => _showComingSoon(
                                  context,
                                  'Help & Support',
                                ),
                              ),
                              const SizedBox(height: 9),

                              _buildMenuCard(
                                context,
                                icon: LucideIcons.info,
                                title: 'About UrbanEye',
                                subtitle:
                                    'Learn more about the application',
                                onTap: () => _showAboutDialog(context),
                              ),
                              const SizedBox(height: 28),

                              _buildLogoutButton(context),
                              const SizedBox(height: 22),

                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'URBANEYE',
                                      style: TextStyle(
                                        color: _secondaryText(context),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Version 1.0.0',
                                      style: TextStyle(
                                        color: _secondaryText(context)
                                            .withValues(alpha: 0.65),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE LOADING AND ERROR STATE
  // ============================================================

  Widget _buildProfileLoadStatus(BuildContext context) {
    final profile = ProfileData.instance;

    if (profile.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border(context)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: purpleLight,
              ),
            ),
            SizedBox(width: 11),
            Expanded(
              child: Text(
                'Loading your profile...',
                style: TextStyle(
                  color: purpleLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (profile.errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: danger.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: danger,
              size: 19,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                profile.errorMessage!,
                style: TextStyle(
                  color: _secondaryText(context),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
            TextButton(
              onPressed: () => profile.loadProfile(),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: purpleLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _topButton(
            context,
            icon: LucideIcons.arrowLeft,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
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
                    color: _primaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'MY PROFILE',
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
    );
  }

  // ============================================================
  // PROFILE HERO
  // ============================================================

  Widget _buildProfileHero(BuildContext context) {
    final name = ProfileData.instance.name;
    final email = ProfileData.instance.email;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: _border(context)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(
              alpha: _isDark(context) ? 0.10 : 0.06,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF4C1D95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withValues(alpha: 0.22),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: purple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: purpleLight.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.shieldCheck,
                            color: purpleLight,
                            size: 12,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'URBANEYE MEMBER',
                            style: TextStyle(
                              color: purpleLight,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
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
          const SizedBox(height: 20),
          Container(height: 1, color: _border(context)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                LucideIcons.activity,
                color: purpleLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your civic activity',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'Active contributor',
                style: TextStyle(
                  color: success.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // REAL DATABASE STATISTICS
  // ============================================================

  Widget _buildStats(BuildContext context) {
    final totalReports = _reports.length;

    final resolvedReports = _reports
        .where((report) => _getStatus(report) == 'resolved')
        .length;

    final pendingReports = _reports
        .where((report) => _getStatus(report) == 'pending')
        .length;

    final totalValue = _reportsLoading
        ? '...'
        : _reportsError != null
            ? '—'
            : totalReports.toString();

    final resolvedValue = _reportsLoading
        ? '...'
        : _reportsError != null
            ? '—'
            : resolvedReports.toString();

    final pendingValue = _reportsLoading
        ? '...'
        : _reportsError != null
            ? '—'
            : pendingReports.toString();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                value: totalValue,
                label: 'Reports',
                icon: LucideIcons.fileText,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildStatItem(
                context,
                value: resolvedValue,
                label: 'Resolved',
                icon: LucideIcons.checkCircle2,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _buildStatItem(
                context,
                value: pendingValue,
                label: 'Pending',
                icon: LucideIcons.clock,
              ),
            ),
          ],
        ),
        if (_reportsError != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  _reportsError!,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11,
                  ),
                ),
              ),
              TextButton(
                onPressed: _loadReportStats,
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: purpleLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border(context)),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _iconBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: purpleLight, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _card(context),
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        splashColor: purple.withValues(alpha: 0.08),
        highlightColor: purple.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _border(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _iconBackground(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: purpleLight, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _primaryText(context),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: _softCard(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border(context)),
                ),
                child: Icon(
                  LucideIcons.chevronRight,
                  color: _secondaryText(context),
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(19),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: danger.withValues(
              alpha: _isDark(context) ? 0.055 : 0.07,
            ),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: danger.withValues(alpha: 0.16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.logOut, size: 18, color: danger),
              SizedBox(width: 9),
              Text(
                'Log Out',
                style: TextStyle(
                  color: danger,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _card(context),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _border(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: danger.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.logOut,
                    color: danger,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  'Log Out?',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to log out of UrbanEye?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryText(context),
                          backgroundColor: _softCard(context),
                          side: BorderSide(color: _border(context)),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final navigator = GoRouter.of(context);
                          final messenger =
                              ScaffoldMessenger.of(context);

                          Navigator.pop(dialogContext);
                          _performLogout(navigator, messenger);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout(
    GoRouter navigator,
    ScaffoldMessengerState messenger,
  ) async {
    try {
      await ApiClient.logout();
      navigator.go('/login');
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not log out. Please try again.'),
        ),
      );
    }
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title will be available soon.'),
        backgroundColor: _card(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // ABOUT DIALOG
  // ============================================================

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _card(context),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: _border(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.info,
                    color: purpleLight,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  'About UrbanEye',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'UrbanEye is an AI-powered civic issue detection '
                  'and smart complaint reporting system designed '
                  'to help identify and report urban infrastructure issues.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 11.5,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TOP BUTTON
  // ============================================================

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
            color: _card(context),
            shape: BoxShape.circle,
            border: Border.all(color: _border(context)),
          ),
          child: Icon(
            icon,
            color: _primaryText(context),
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE BACKGROUND
// ============================================================

class _ProfileBackground extends StatelessWidget {
  final bool isDark;

  const _ProfileBackground({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.22, 0.52, 1.0],
            colors: isDark
                ? const [
                    Color(0xFF6E3BA7),
                    Color(0xFF2B1446),
                    Color(0xFF0D0B12),
                    Color(0xFF000000),
                  ]
                : const [
                    Color(0xFFEFE3F8),
                    Color(0xFFF6F0FA),
                    Color(0xFFFAF8FC),
                    Color(0xFFF8F7FC),
                  ],
          ),
        ),
      ),
    );
  }
}