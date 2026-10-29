import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppIconBadge extends StatelessWidget {
  const AppIconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox.square(
      dimension: AppSizes.badge,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary.withValues(alpha: AppOpacity.soft),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: Icon(icon, size: AppSizes.iconMd, color: primary),
        ),
      ),
    );
  }
}
