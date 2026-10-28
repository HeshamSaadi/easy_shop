import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// One row of the recent orders and products overview lists.
class HomeListItem extends StatelessWidget {
  const HomeListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.label,
    this.trailingText,
  });

  final String title;
  final String subtitle;

  /// Status widget shown under [trailingText].
  final Widget label;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trailing = trailingText;

    return AppCard(
      padding: AppSpacing.md,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (trailing != null)
                Text(trailing, style: theme.textTheme.titleMedium),
              label,
            ],
          ),
        ],
      ),
    );
  }
}
