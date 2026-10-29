import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

/// rounded square with a soft orange background and an icon
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({super.key, required this.icon});

  final IconData icon;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Icon(icon, size: AppSizes.iconMd, color: primary),
        ),
      ),
    );
  }
}
