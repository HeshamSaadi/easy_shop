//!نقطة مركزية لتجميع إعدادات الـ Theme وتوفيرها للتطبيق.

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_light_theme.dart';
import 'app_dark_theme.dart';

class AppTheme {
  AppTheme._();

  //! Admin App Themes
  static ThemeData get lightTheme {
    return AppLightTheme.theme;
  }

  static ThemeData get darkTheme {
    return AppDarkTheme.theme;
  }

  //! Client App Themes (uses different primary color)
  static ThemeData get clientLightTheme {
    return AppLightTheme.themeWithPrimary(AppColors.clientPrimary);
  }

  static ThemeData get clientDarkTheme {
    return AppDarkTheme.themeWithPrimary(AppColors.clientPrimary);
  }

  static const ThemeMode defaultMode = ThemeMode.system;
}
