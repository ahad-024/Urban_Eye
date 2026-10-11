
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _animationController;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // LOGIN WITH DJANGO REST API
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiClient.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to connect to UrbanEye server. '
            'Check that the backend is running and the API URL is correct.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _goToRegister() {
    context.go('/register');
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters';
    }

    return null;
  }

  // FORGOT PASSWORD SHEET
  void _showForgotPassword() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151217) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Forgot password?',
                  style: AppTextStyles.heading2.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 9),
                Text(
                  'Enter your email address to begin resetting your password.',
                  style: AppTextStyles.body.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();

                        if (email.isEmpty ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid email address.'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password reset is not connected to the backend yet.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: Text(
                        'Send Reset Link',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(emailController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);

    final secondaryText =
        theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white70 : Colors.black54);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(isDark),
          SafeArea(
            child: GestureDetector(
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
                      const SizedBox(height: 46),
                      _buildWelcomeSection(primaryText, secondaryText),
                      const SizedBox(height: 34),
                      _buildLabel('Email address', primaryText),
                      const SizedBox(height: 9),
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildLabel('Password', primaryText),
                      const SizedBox(height: 9),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      _buildRememberForgotRow(),
                      const SizedBox(height: 26),
                      _buildLoginButton(),
                      const SizedBox(height: 30),
                      _buildDivider(secondaryText),
                      const SizedBox(height: 28),
                      _buildRegisterPrompt(secondaryText),
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

  // ANIMATED PURPLE BACKGROUND
  Widget _buildAnimatedBackground(bool isDark) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value * math.pi * 2;
        final x = math.sin(value) * 35;
        final y = math.cos(value) * 25;

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -125 + y,
                right: -105 + x,
                child: _glowCircle(
                  300,
                  AppColors.purple.withValues(
                    alpha: isDark ? 0.14 : 0.055,
                  ),
                ),
              ),
              Positioned(
                top: 220 - y,
                left: -180 - x,
                child: _glowCircle(
                  310,
                  AppColors.deepPurple.withValues(
                    alpha: isDark ? 0.08 : 0.035,
                  ),
                ),
              ),
              Positioned(
                bottom: -160 + x,
                right: -120 - y,
                child: _glowCircle(
                  280,
                  AppColors.purple.withValues(
                    alpha: isDark ? 0.055 : 0.025,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // LOGO AND APP NAME
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

  // WELCOME TEXT
  Widget _buildWelcomeSection(
    Color primaryText,
    Color secondaryText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: AppTextStyles.heading1.copyWith(
            color: primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Sign in to continue using UrbanEye.',
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

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // EMAIL INPUT
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: _validateEmail,
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
      decoration: const InputDecoration(
        hintText: 'Enter your email',
        prefixIcon: Icon(Icons.email_outlined),
      ).copyWith(
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppColors.purple,
        ),
      ),
    );
  }

  // PASSWORD INPUT
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: _validatePassword,
      onFieldSubmitted: (_) => _login(),
      decoration: InputDecoration(
        hintText: 'Enter your password',
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

  // REMEMBER ME AND FORGOT PASSWORD
  Widget _buildRememberForgotRow() {
    return Row(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (value) {
              setState(() => _rememberMe = value ?? false);
            },
            activeColor: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Remember me',
          style: AppTextStyles.bodyMedium,
        ),
        const Spacer(),
        TextButton(
          onPressed: _showForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
          ),
          child: Text(
            'Forgot password?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.purple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // SIGN-IN BUTTON
  Widget _buildLoginButton() {
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
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledForegroundColor: Colors.white,
            foregroundColor: Colors.white,
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
                        'Sign In',
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

  // OR DIVIDER
  Widget _buildDivider(Color secondaryText) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: AppTextStyles.caption.copyWith(
              color: secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ],
    );
  }

  // REGISTER LINK
  Widget _buildRegisterPrompt(Color secondaryText) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: AppTextStyles.body.copyWith(
              color: secondaryText,
            ),
          ),
          GestureDetector(
            onTap: _goToRegister,
            child: Text(
              'Create account',
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