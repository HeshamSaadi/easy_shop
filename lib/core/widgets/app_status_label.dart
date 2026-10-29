import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Small status pill with a colored dot
class AppStatusLabel extends StatelessWidget {
  const AppStatusLabel({super.key, required this.text, this.color});

  final String text;

  /// Falls back to the secondary text color of the theme.
  final Color? color;

  static const double _dotSize = 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: _dotSize),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
