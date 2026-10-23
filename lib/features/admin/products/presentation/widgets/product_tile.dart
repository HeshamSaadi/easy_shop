import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  static const double _imageSize = 56;
  static const int _decimals = 2;

  String get _price {
    final value = product.price;
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(_decimals);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.md);
    final categoryName = product.category?.name;

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
              _Thumbnail(url: product.imageUrl, size: _imageSize),
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
                      '$_price  ·  ${ProductsStrings.quantity(product.quantity)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _VisibilityBadge(isVisible: product.isVisible),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallback = Icon(
      Icons.image_outlined,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: SizedBox.square(
        dimension: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(child: fallback),
        ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.isVisible});

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
