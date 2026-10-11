import 'package:flutter/material.dart';

class AppColors {
  // Primary Purple
  static const Color deepPurple = Color(0xFF5B21B6);
  static const Color darkPurple = Color(0xFF3B0764);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFA78BFA);
  static const Color lightPurple = Color(0xFFEDE9FE);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8F7FC);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F0B18);
  static const Color darkSurface = Color(0xFF14101D);
  static const Color darkCard = Color(0xFF181221);

  // Text
  static const Color primaryText = Color(0xFF17121F);
  static const Color secondaryText = Color(0xFF8A8494);
  static const Color darkPrimaryText = Color(0xFFF8F7FC);
  static const Color darkSecondaryText = Color(0xFFA9A3B2);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Neutral
  static const Color divider = Color(0xFFE8E4EE);
  static const Color darkDivider = Color(0xFF292331);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      darkPurple,
      deepPurple,
      purple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softPurpleGradient = LinearGradient(
    colors: [
      Color(0xFFEDE9FE),
      Color(0xFFF5F3FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}