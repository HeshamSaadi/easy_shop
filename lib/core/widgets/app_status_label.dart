import 'package:flutter/material.dart';

/// Small colored status text, such as Visible, Hidden or Pending.
class AppStatusLabel extends StatelessWidget {
  const AppStatusLabel({super.key, required this.text, this.color});

  final String text;

  /// Falls back to the secondary text color of the theme.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
