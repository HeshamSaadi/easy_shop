import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:flutter/material.dart';

class ProductVisibilityBadge extends StatelessWidget {
  const ProductVisibilityBadge({super.key, required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isVisible
        ? AppColors.success
        : theme.colorScheme.onSurfaceVariant;

    return Text(
      isVisible ? ProductsStrings.visible : ProductsStrings.hidden,
      style: theme.textTheme.bodySmall?.copyWith(color: color),
    );
  }
}
