//!نقطة مركزية لتجميع إعدادات الـ Theme وتوفيرها للتطبيق.

import 'package:flutter/material.dart';

import 'app_light_theme.dart';
import 'app_dark_theme.dart';

class AppTheme {
  AppTheme._();

  //! light Mode
  static ThemeData get lightTheme {
    return AppLightTheme.theme;
  }

  //! Dark Mode
  static ThemeData get darkTheme {
    return AppDarkTheme.theme;
  }

  static const ThemeMode defaultMode = ThemeMode.light;
}
