
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/api/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  late final AnimationController _animationController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  // REGISTER WITH DJANGO

  Future<void> _register() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showMessage(
        'Please accept the Terms of Service and Privacy Policy.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      // Create the account in Django.
      await ApiClient.register(
        username: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Registration does not return JWT tokens in the current API.
      // Log in to obtain and save the access and refresh tokens.
      await ApiClient.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Account created successfully.');

      // The user is authenticated now.
      context.go('/home');
    } on ApiException catch (error) {
      if (!mounted) return;

      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to connect to UrbanEye. Check your connection and try again.',
      );

      debugPrint('Registration error: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void _goToLogin() {
    if (_isLoading) return;
    context.go('/login');
  }

  // VALIDATORS

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your full name';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please create a password';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    final secondaryText = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 42),
                      _buildWelcomeSection(
                        primaryText,
                        secondaryText,
                      ),
                      const SizedBox(height: 32),
                      _buildLabel('Full name', primaryText),
                      const SizedBox(height: 9),
                      _buildNameField(),
                      const SizedBox(height: 19),
                      _buildLabel('Email address', primaryText),
                      const SizedBox(height: 9),
                      _buildEmailField(),
                      const SizedBox(height: 19),
                      _buildLabel('Password', primaryText),
                      const SizedBox(height: 9),
                      _buildPasswordField(),
                      const SizedBox(height: 19),
                      _buildLabel('Confirm password', primaryText),
                      const SizedBox(height: 9),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 17),
                      _buildTermsCheckbox(secondaryText),
                      const SizedBox(height: 25),
                      _buildRegisterButton(),
                      const SizedBox(height: 30),
                      _buildLoginPrompt(secondaryText),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ANIMATED BACKGROUND

  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value * math.pi * 2;
        final x = math.sin(value) * 32;
        final y = math.cos(value) * 24;

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -130 + y,
                right: -110 + x,
                child: Container(
                  width: 310,
                  height: 310,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple.withValues(
                      alpha: isDark ? 0.15 : 0.055,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 260 - y,
                left: -190 - x,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepPurple.withValues(
                      alpha: isDark ? 0.08 : 0.035,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -180 + x,
                right: -130 - y,
                child: Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple.withValues(
                      alpha: isDark ? 0.05 : 0.025,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.27),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.visibility_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'UrbanEye',
          style: AppTextStyles.heading3,
        ),
      ],
    );
  }

  // WELCOME

  Widget _buildWelcomeSection(
    Color primaryText,
    Color secondaryText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: AppTextStyles.heading1.copyWith(
            color: primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Join UrbanEye and help build smarter communities.',
          style: AppTextStyles.body.copyWith(
            color: secondaryText,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              width: 7,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // LABEL

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // NAME

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocus,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      validator: _validateName,
      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
      decoration: InputDecoration(
        hintText: 'Enter your full name',
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppColors.purple,
        ),
      ),
    );
  }

  // EMAIL

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: _validateEmail,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      decoration: InputDecoration(
        hintText: 'Enter your email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppColors.purple,
        ),
      ),
    );
  }

  // PASSWORD

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.newPassword],
      validator: _validatePassword,
      onChanged: (_) {
        if (_confirmPasswordController.text.isNotEmpty) {
          _formKey.currentState?.validate();
        }
      },
      onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
      decoration: InputDecoration(
        hintText: 'Create a password',
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.purple,
        ),
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  // CONFIRM PASSWORD

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.newPassword],
      validator: _validateConfirmPassword,
      onFieldSubmitted: (_) => _register(),
      decoration: InputDecoration(
        hintText: 'Confirm your password',
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.purple,
        ),
        suffixIcon: IconButton(
          tooltip: _obscureConfirmPassword
              ? 'Show password'
              : 'Hide password',
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  // TERMS

  Widget _buildTermsCheckbox(Color secondaryText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() => _agreeToTerms = value ?? false);
                  },
            activeColor: AppColors.purple,
            checkColor: Colors.white,
            side: BorderSide(
              color: secondaryText.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: AppTextStyles.small.copyWith(
                  color: secondaryText,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // REGISTER BUTTON

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.28),
              blurRadius: 23,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey('button'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: AppTextStyles.button,
                      ),
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // LOGIN PROMPT

  Widget _buildLoginPrompt(Color secondaryText) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: AppTextStyles.body.copyWith(
              color: secondaryText,
            ),
          ),
          GestureDetector(
            onTap: _goToLogin,
            child: Text(
              'Sign in',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.purple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}