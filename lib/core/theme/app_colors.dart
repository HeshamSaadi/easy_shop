import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors: shared between Light and Dark modes
  static const Color primary = Color(0xFFF5821F);
  static const Color primaryLight = Color(0xFFF6BD8D);
  static const Color primarySoft = Color(0xFFFFF4EC);

  // Light Mode: backgrounds and surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF2F2F7);

  // Light Mode: text and borders
  static const Color textPrimary = Color(0xFF1A1A28);
  static const Color textSecondary = Color(0xFF8A8A9E);
  static const Color border = Color(0xFFE5E5EC);

  // Dark Mode: backgrounds and surfaces
  static const Color darkBackground = Color(0xFF121318);
  static const Color darkSurface = Color(0xFF1C1D25);
  static const Color darkInputBackground = Color(0xFF252631);

  // Dark Mode: text and borders
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFFB1B2C0);
  static const Color darkBorder = Color(0xFF383945);

  // Success Colors
  static const Color success = Color(0xFF0F9F6F);
  static const Color successBackground = Color(0xFFD1FAE5);
  static const Color darkSuccessBackground = Color(0xFF16352B);

  // Warning Colors
  static const Color warning = Color(0xFFD97706);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color darkWarningBackground = Color(0xFF3B2D16);

  // Error Colors
  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEE2E2);
  static const Color darkErrorBackground = Color(0xFF3B2023);

  // Information Colors
  static const Color info = Color(0xFF155DFC);
  static const Color infoBackground = Color(0xFFDBEAFE);
  static const Color darkInfoBackground = Color(0xFF1B2D4A);
}
