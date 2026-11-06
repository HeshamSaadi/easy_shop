import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The surface used for blocks on admin screens (home, orders).
///
/// By default it is a bordered surface. With [borderless] it blends into
/// the screen background and has no border (the Home look).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.lg,
    this.borderless = false,
  });

  final Widget child;
  final double padding;
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: borderless
            ? theme.scaffoldBackgroundColor
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: borderless ? null : Border.all(color: theme.dividerColor),
      ),
      child: child,
    );
  }
}
