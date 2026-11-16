import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/client/products/presentation/constants/product_details_strings.dart';
import 'package:flutter/material.dart';

/// Green box with the units in stock, or a red "Out of Stock" box.
class StockBox extends StatelessWidget {
  const StockBox({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inStock = stock > 0;
    final color = inStock ? AppColors.success : theme.colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.tint),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inStock
                  ? ProductDetailsStrings.inStock
                  : ProductDetailsStrings.outOfStock,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
            if (inStock)
              Text(
                ProductDetailsStrings.units(stock),
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
          ],
        ),
      ),
    );
  }
}
