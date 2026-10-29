import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/utils/product_formatters.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_visibility_badge.dart';
import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  static const double _imageSize = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.md);
    final categoryName = product.category?.name;
    final price = ProductFormatters.price(product.price);
    final quantity = ProductsStrings.quantity(product.quantity);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: _imageSize,
                child: AppNetworkImage(url: product.imageUrl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (categoryName != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(categoryName, style: theme.textTheme.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$price  ·  $quantity',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ProductVisibilityBadge(isVisible: product.isVisible),
            ],
          ),
        ),
      ),
    );
  }
}
