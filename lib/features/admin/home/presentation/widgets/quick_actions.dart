import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onAddProduct,
    required this.onManageCategories,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onManageCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // IntrinsicHeight keeps both buttons the same height if a label wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add),
              label: const Text(HomeStrings.addProduct),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onManageCategories,
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                backgroundColor: primary.withValues(alpha: AppOpacity.soft),
                side: BorderSide(
                  color: primary.withValues(alpha: AppOpacity.outline),
                ),
                textStyle: theme.textTheme.labelLarge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.sell_outlined),
              label: const Text(HomeStrings.manageCategories),
            ),
          ),
        ],
      ),
    );
  }
}
