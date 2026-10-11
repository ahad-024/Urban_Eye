import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color success = Color(0xFF63D39A);
  static const Color danger = Color(0xFFFF6B6B);

  bool notificationsEnabled = true;
  bool locationEnabled = true;
  bool analysisNotifications = true;
  bool complaintUpdates = true;
  bool preferencesLoading = true;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

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

  Color get iconSecondary =>
      isDark ? const Color(0xFFB0B0B8) : const Color(0xFF77727F);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved switches.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        notificationsEnabled =
            prefs.getBool('settings_notifications') ?? true;
        locationEnabled =
            prefs.getBool('settings_location') ?? true;
        analysisNotifications =
            prefs.getBool('settings_ai_alerts') ?? true;
        complaintUpdates =
            prefs.getBool('settings_complaint_updates') ?? true;
        preferencesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => preferencesLoading = false);
    }
  }

  // Save a preference immediately.
  Future<void> _savePreference(
    String key,
    bool value,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not save this preference.');
    }
  }

  void _updatePreference(
    String key,
    bool value,
    ValueChanged<bool> update,
  ) {
    setState(() => update(value));
    _savePreference(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            const _SettingsBackground(),
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 25),
                      _sectionTitle('PREFERENCES'),
                      const SizedBox(height: 10),
                      _buildPreferencesCard(),
                      const SizedBox(height: 24),
                      _sectionTitle('REPORTING'),
                      const SizedBox(height: 10),
                      _buildReportingCard(),
                      const SizedBox(height: 24),
                      _sectionTitle('ACCOUNT & PRIVACY'),
                      const SizedBox(height: 10),
                      _buildAccountCard(),
                      const SizedBox(height: 24),
                      _sectionTitle('SUPPORT'),
                      const SizedBox(height: 10),
                      _buildSupportCard(),
                      const SizedBox(height: 28),
                      _buildVersion(),
                    ],
                  ),
                ),
              ],
            ),
            if (preferencesLoading)
              Positioned(
                top: 0,
                right: 16,
                child: IgnorePointer(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: purpleLight,
                    ),
                  ),
                ),
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
                    color: primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'SETTINGS',
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

  // HEADER

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 28,
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
                colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              LucideIcons.settings2,
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
                  'App Settings',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Customize your UrbanEye experience.',
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

  // PREFERENCES

  Widget _buildPreferencesCard() {
    return _container([
      _switchTile(
        icon: LucideIcons.bell,
        iconColor: purpleLight,
        title: 'Notifications',
        subtitle: 'Receive UrbanEye updates',
        value: notificationsEnabled,
        onChanged: (value) => _updatePreference(
          'settings_notifications',
          value,
          (v) => notificationsEnabled = v,
        ),
      ),
      _divider(),
      _actionTile(
        icon: LucideIcons.palette,
        iconColor: purpleLight,
        title: 'Appearance',
        subtitle: _appearanceSubtitle(),
        trailing: AnimatedBuilder(
          animation: themeController,
          builder: (_, __) => Text(
            _appearanceLabel(),
            style: const TextStyle(
              color: purpleLight,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
        onTap: _showAppearanceSheet,
      ),
    ]);
  }

  String _appearanceLabel() {
    switch (themeController.themeMode) {
      case ThemeMode.light:
        return 'LIGHT';
      case ThemeMode.dark:
        return 'DARK';
      case ThemeMode.system:
        return 'SYSTEM';
    }
  }

  String _appearanceSubtitle() {
    switch (themeController.themeMode) {
      case ThemeMode.light:
        return 'Light appearance';
      case ThemeMode.dark:
        return 'Dark premium theme';
      case ThemeMode.system:
        return 'Follow device settings';
    }
  }

  // REPORTING

  Widget _buildReportingCard() {
    return _container([
      _switchTile(
        icon: LucideIcons.mapPin,
        iconColor: success,
        title: 'Location Services',
        subtitle: 'Use location when submitting reports',
        value: locationEnabled,
        onChanged: (value) => _updatePreference(
          'settings_location',
          value,
          (v) => locationEnabled = v,
        ),
      ),
      _divider(),
      _switchTile(
        icon: LucideIcons.sparkles,
        iconColor: purpleLight,
        title: 'AI Analysis Alerts',
        subtitle: 'Notify when image analysis is complete',
        value: analysisNotifications,
        onChanged: (value) => _updatePreference(
          'settings_ai_alerts',
          value,
          (v) => analysisNotifications = v,
        ),
      ),
      _divider(),
      _switchTile(
        icon: LucideIcons.fileCheck2,
        iconColor: success,
        title: 'Complaint Updates',
        subtitle: 'Receive status updates for complaints',
        value: complaintUpdates,
        onChanged: (value) => _updatePreference(
          'settings_complaint_updates',
          value,
          (v) => complaintUpdates = v,
        ),
      ),
    ]);
  }

  // ACCOUNT

  Widget _buildAccountCard() {
    return _container([
      _actionTile(
        icon: LucideIcons.user,
        iconColor: purpleLight,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        onTap: () => context.push('/edit-profile'),
      ),
      _divider(),
      _actionTile(
        icon: LucideIcons.lock,
        iconColor: danger,
        title: 'Privacy & Security',
        subtitle: 'Manage your privacy preferences',
        onTap: _showPrivacyDialog,
      ),
      _divider(),
      _actionTile(
        icon: LucideIcons.shieldCheck,
        iconColor: success,
        title: 'Data & Permissions',
        subtitle: 'Review app permissions',
        onTap: _showPermissionsDialog,
      ),
    ]);
  }

  // SUPPORT

  Widget _buildSupportCard() {
    return _container([
      _actionTile(
        icon: LucideIcons.helpCircle,
        iconColor: purpleLight,
        title: 'Help & Support',
        subtitle: 'Get help using UrbanEye',
        onTap: () {
          // Register /help-support in GoRouter for this navigation.
          context.push('/help-support');
        },
      ),
      _divider(),
      _actionTile(
        icon: LucideIcons.info,
        iconColor: iconSecondary,
        title: 'About UrbanEye',
        subtitle: 'Learn more about the project',
        onTap: _showAboutDialog,
      ),
    ]);
  }

  // SHARED COMPONENTS

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
      padding: const EdgeInsets.only(left: 70, right: 16),
      child: Container(height: 1, color: border),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: purple,
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.10),
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
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
              if (trailing != null) ...[
                trailing,
                const SizedBox(width: 10),
              ],
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

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }

  // VERSION

  Widget _buildVersion() {
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

  // APPEARANCE

  void _showAppearanceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            final dark =
                Theme.of(context).brightness == Brightness.dark;
            final currentMode = themeController.themeMode;
            final sheetColor =
                dark ? const Color(0xFF121016) : Colors.white;
            final textColor =
                Theme.of(context).colorScheme.onSurface;
            final subColor = dark
                ? const Color(0xFFB0B0B8)
                : const Color(0xFF6B6675);

            return Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              decoration: BoxDecoration(
                color: sheetColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border(top: BorderSide(color: border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose how UrbanEye looks on your device.',
                      style: TextStyle(color: subColor, fontSize: 10.5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _appearanceOption(
                    icon: LucideIcons.moon,
                    title: 'Dark',
                    subtitle: 'Premium dark appearance',
                    selected: currentMode == ThemeMode.dark,
                    dark: dark,
                    onTap: () => _changeTheme(
                      ThemeMode.dark,
                      sheetContext,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _appearanceOption(
                    icon: LucideIcons.sun,
                    title: 'Light',
                    subtitle: 'Clean light appearance',
                    selected: currentMode == ThemeMode.light,
                    dark: dark,
                    onTap: () => _changeTheme(
                      ThemeMode.light,
                      sheetContext,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _appearanceOption(
                    icon: LucideIcons.smartphone,
                    title: 'System',
                    subtitle: 'Follow device settings',
                    selected: currentMode == ThemeMode.system,
                    dark: dark,
                    onTap: () => _changeTheme(
                      ThemeMode.system,
                      sheetContext,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changeTheme(ThemeMode mode, BuildContext sheetContext) {
    themeController.setThemeMode(mode);
    Navigator.pop(sheetContext);

    if (!mounted) return;

    final message = switch (mode) {
      ThemeMode.dark => 'Dark theme enabled',
      ThemeMode.light => 'Light theme enabled',
      ThemeMode.system => 'System theme enabled',
    };

    _showSnackBar(message);
  }

  Widget _appearanceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required bool dark,
  }) {
    final subColor = dark
        ? const Color(0xFFB0B0B8)
        : const Color(0xFF6B6675);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? purple.withValues(alpha: 0.10)
                : dark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? purple.withValues(alpha: 0.35)
                  : dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            children: [
              _iconBox(icon, selected ? purpleLight : subColor),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black87,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: subColor, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  LucideIcons.checkCircle2,
                  color: purpleLight,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // INFORMATION DIALOGS

  void _showPrivacyDialog() {
    _showInfoDialog(
      icon: LucideIcons.lock,
      iconColor: danger,
      title: 'Privacy & Security',
      message:
          'UrbanEye uses your submitted information to support civic issue reporting and analysis.\n\n'
          'Your account is protected by the authentication system configured for the app. '
          'Only share information necessary to submit a civic report.',
      buttonText: 'Done',
    );
  }

  void _showPermissionsDialog() {
    _showInfoDialog(
      icon: LucideIcons.shieldCheck,
      iconColor: success,
      title: 'Data & Permissions',
      message:
          'UrbanEye may use your camera, photo gallery and location when you submit a civic issue.\n\n'
          'You can manage these permissions from your device settings. '
          'Turning off location here saves your preference, but device permissions are managed separately.',
      buttonText: 'Got it',
    );
  }

  void _showAboutDialog() {
    _showInfoDialog(
      icon: LucideIcons.building2,
      iconColor: purpleLight,
      title: 'About UrbanEye',
      message:
          'UrbanEye is an AI-based civic issue detection and severity assessment system designed to help communities report infrastructure issues.\n\n'
          'Supported issue categories include potholes, road cracks, garbage, street lights and water overflow.',
      buttonText: 'Close',
    );
  }

  void _showInfoDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dark =
            Theme.of(dialogContext).brightness == Brightness.dark;
        final textColor = dark ? Colors.white : Colors.black87;
        final subColor = dark
            ? const Color(0xFFB0B0B8)
            : const Color(0xFF6B6675);

        return Dialog(
          backgroundColor:
              dark ? const Color(0xFF1C1C1E) : Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: iconColor, size: 25),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 21),
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
                    child: Text(
                      buttonText,
                      style: const TextStyle(
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

  void _showSnackBar(String message) {
    if (!mounted) return;

    final dark = isDark;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: dark ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor:
              dark ? const Color(0xFF1C1C1E) : Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
        ),
      );
  }
}

class _SettingsBackground extends StatelessWidget {
  const _SettingsBackground();

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
