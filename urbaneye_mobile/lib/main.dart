
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

// AUTH & STARTUP
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// HOME
import 'screens/home/home_screen.dart';

// PROFILE
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

// NOTIFICATIONS & SETTINGS
import 'screens/notifications/notifications_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/help_support_screen.dart';

// CAPTURE
import 'screens/capture/capture_screen.dart';
import 'screens/capture/image_preview_screen.dart';

// AI
import 'screens/ai/ai_loading_screen.dart';
import 'screens/ai/ai_result_screen.dart';

// COMPLAINT
import 'screens/complaint/submit_complaint_screen.dart';
import 'screens/complaint/complaint_success_screen.dart';

// LOCATION
import 'screens/location/location_picker_screen.dart';

// REPORTS
import 'screens/reports/reports_screen.dart';
import 'screens/reports/report_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrbanEyeApp());
}

class UrbanEyeApp extends StatefulWidget {
  const UrbanEyeApp({super.key});

  @override
  State<UrbanEyeApp> createState() => _UrbanEyeAppState();
}

class _UrbanEyeAppState extends State<UrbanEyeApp> {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/report-details',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is Map<String, dynamic>) {
            return ReportDetailsScreen(report: extra);
          }

          return const _ErrorScreen(
            message: 'Report data not available',
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/capture',
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: '/image-preview',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is XFile) {
            return ImagePreviewScreen(image: extra);
          }

          return const _ErrorScreen(
            message: 'Image not available',
          );
        },
      ),
      GoRoute(
        path: '/ai-loading',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is XFile) {
            return AiLoadingScreen(image: extra);
          }

          return const _ErrorScreen(
            message: 'Image not available',
          );
        },
      ),
      GoRoute(
        path: '/ai-result',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is XFile) {
            return AiResultScreen(image: extra);
          }

          return const _ErrorScreen(
            message: 'Image not available',
          );
        },
      ),
      GoRoute(
        path: '/submit-complaint',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is Map<String, dynamic>) {
            final image = extra['image'];

            if (image is XFile) {
              final confidenceValue = extra['confidence'];

              final int confidence = confidenceValue is int
                  ? confidenceValue
                  : int.tryParse(
                        confidenceValue?.toString() ?? '',
                      ) ??
                      0;

              return SubmitComplaintScreen(
                image: image,
                issueType:
                    extra['issueType']?.toString() ?? 'Pothole',
                severity:
                    extra['severity']?.toString() ?? 'High',
                confidence: confidence,
              );
            }
          }

          return const _ErrorScreen(
            message: 'Complaint data not available',
          );
        },
      ),
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: '/complaint-success',
        builder: (context, state) {
          final extra = state.extra;
          final data = extra is Map<String, dynamic>
              ? extra
              : <String, dynamic>{};

          return ComplaintSuccessScreen(
            issueType:
                data['issueType']?.toString() ?? 'Pothole',
            severity:
                data['severity']?.toString() ?? 'High',
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'UrbanEye',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: 0.60,
                  ),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}