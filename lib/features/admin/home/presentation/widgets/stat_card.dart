import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// One number with an icon and a label, on a tile with its own background.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconLg, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count', style: theme.textTheme.titleLarge),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
