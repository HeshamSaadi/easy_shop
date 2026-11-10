import 'package:flutter/material.dart';

/// Colors of the current theme that Flutter's ColorScheme has no slot for.
extension AppThemeColors on ThemeData {
  /// Secondary text (hints, captions): `textSecondary` in light mode and
  /// `darkTextSecondary` in dark mode, as both themes set it on `bodySmall`.
  Color get mutedText => textTheme.bodySmall?.color ?? colorScheme.onSurface;
}
