import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/api/api_client.dart';
import '../../models/profile_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _isSaving = false;

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFB78BEA);
  static const Color danger = Color(0xFFFF6B6B);

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  Color _primaryText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryText(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB0B0B8) : const Color(0xFF6B6675);

  Color _card(BuildContext context) =>
      _isDark(context) ? const Color(0xFF181221) : Colors.white;

  Color _cardSoft(BuildContext context) =>
      _isDark(context) ? const Color(0xFF141018) : const Color(0xFFF5F1F8);

  Color _input(BuildContext context) =>
      _isDark(context) ? const Color(0xFF17131F) : const Color(0xFFF8F6FA);

  Color _border(BuildContext context) => _isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.07);

  Color _inputBorder(BuildContext context) => _isDark(context)
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.06);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: ProfileData.instance.name,
    );
    _emailController = TextEditingController(
      text: ProfileData.instance.email,
    );

    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // SAVE PROFILE TO DJANGO

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      final updatedProfile = await ApiClient.updateProfile(
        username: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      final savedUsername =
          updatedProfile['username']?.toString() ??
          _nameController.text.trim();

      final savedEmail =
          updatedProfile['email']?.toString() ??
          _emailController.text.trim();

      // Update shared app state only after the server succeeds.
      ProfileData.instance.updateProfile(
        name: savedUsername,
        email: savedEmail,
      );

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                LucideIcons.checkCircle2,
                color: Colors.white,
                size: 19,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Profile updated successfully'),
              ),
            ],
          ),
          backgroundColor: _isDark(context)
              ? const Color(0xFF181221)
              : const Color(0xFF29232F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 400),
      );

      if (!mounted) return;

      context.pop();
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update profile. Check your connection and try again.',
          ),
          backgroundColor: Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),
      body: SafeArea(
        child: Stack(
          children: [
            _EditProfileBackground(isDark: _isDark(context)),
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(context),
                          const SizedBox(height: 30),
                          _buildSectionHeader(context),
                          const SizedBox(height: 16),
                          _buildNameField(context),
                          const SizedBox(height: 16),
                          _buildEmailField(context),
                          const SizedBox(height: 20),
                          _buildInfoCard(context),
                          const SizedBox(height: 28),
                          _buildSaveButton(context),
                          const SizedBox(height: 10),
                          _buildCancelButton(context),
                          const SizedBox(height: 20),
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
  }

  // TOP BAR

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _topButton(
            context,
            icon: LucideIcons.arrowLeft,
            onTap: _isSaving ? null : () => context.pop(),
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
                  'EDIT PROFILE',
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

  // PROFILE HEADER

  Widget _buildProfileHeader(BuildContext context) {
    final name = _nameController.text.trim();

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 102,
                height: 102,
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
                      color: purple.withValues(
                        alpha: _isDark(context) ? 0.25 : 0.16,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: _card(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: _border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: _isDark(context) ? 0.35 : 0.10,
                      ),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.camera,
                  size: 16,
                  color: purpleLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Profile Information',
            style: TextStyle(
              color: _primaryText(context),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Update your UrbanEye account details',
            style: TextStyle(
              color: _secondaryText(context),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
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

  // SECTION HEADER

  Widget _buildSectionHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            color: _primaryText(context),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Keep your account information up to date.',
          style: TextStyle(
            color: _secondaryText(context),
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // NAME FIELD

  Widget _buildNameField(BuildContext context) {
    return _buildInputContainer(
      context,
      child: TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          color: purpleLight,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        cursorColor: purpleLight,
        decoration: _inputDecoration(
          context,
          label: 'Username',
          hint: 'Enter your username',
          icon: LucideIcons.user,
        ),
        validator: (value) {
          final username = value?.trim() ?? '';

          if (username.isEmpty) {
            return 'Username is required';
          }

          if (username.length < 3) {
            return 'Username must be at least 3 characters';
          }

          return null;
        },
      ),
    );
  }

  // EMAIL FIELD

  Widget _buildEmailField(BuildContext context) {
    return _buildInputContainer(
      context,
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        style: const TextStyle(
          color: purpleLight,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        cursorColor: purpleLight,
        decoration: _inputDecoration(
          context,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: LucideIcons.mail,
        ),
        validator: (value) {
          final email = value?.trim() ?? '';

          if (email.isEmpty) {
            return 'Email is required';
          }

          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
              .hasMatch(email)) {
            return 'Enter a valid email';
          }

          return null;
        },
      ),
    );
  }

  // INPUT CONTAINER

  Widget _buildInputContainer(
    BuildContext context, {
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _input(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _inputBorder(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: _isDark(context) ? 0.18 : 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // INPUT DECORATION

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: _secondaryText(context),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: const TextStyle(
        color: purpleLight,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: _secondaryText(context).withValues(alpha: 0.48),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: purpleLight, size: 19),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: purple.withValues(alpha: 0.75),
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: danger.withValues(alpha: 0.65),
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: danger,
          width: 1.2,
        ),
      ),
      errorStyle: const TextStyle(
        color: danger,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // INFORMATION CARD

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardSoft(context),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.info,
              color: purpleLight,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile information',
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your email is used for your UrbanEye account. '
                  'Profile changes are saved to your account '
                  'when the server confirms them.',
                  style: TextStyle(
                    color: _secondaryText(context),
                    fontSize: 10.5,
                    height: 1.5,
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

  // SAVE BUTTON

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: purple.withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.save, size: 18),
                  SizedBox(width: 9),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // CANCEL BUTTON

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isSaving ? null : () => context.pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText(context),
          backgroundColor: _card(context),
          disabledForegroundColor:
              _secondaryText(context).withValues(alpha: 0.4),
          side: BorderSide(color: _border(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // TOP BUTTON

  Widget _topButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
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
            color: onTap == null
                ? _secondaryText(context).withValues(alpha: 0.4)
                : _primaryText(context),
            size: 19,
          ),
        ),
      ),
    );
  }
}

// BACKGROUND

class _EditProfileBackground extends StatelessWidget {
  final bool isDark;

  const _EditProfileBackground({
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