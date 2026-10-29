import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/utils/product_formatters.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_image.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_visibility_badge.dart';
import 'package:flutter/material.dart';

class ProductDetailsBody extends StatelessWidget {
  const ProductDetailsBody({
    super.key,
    required this.product,
    required this.onEdit,
  });

  final ProductEntity product;
  final VoidCallback onEdit;

  static const double _imageAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = product.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: _imageAspectRatio,
                  child: ProductImage(
                    url: product.imageUrl,
                    radius: AppRadius.lg,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(product.name, style: theme.textTheme.titleLarge),
                if (product.category != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.category!.name,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: ProductsStrings.priceLabel,
                        value: ProductFormatters.price(product.price),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _StatCard(
                        label: ProductsStrings.stockLabel,
                        value: '${product.quantity}',
                      ),
                    ),
                  ],
                ),
                if (hasDescription) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    ProductsStrings.descriptionTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  ProductsStrings.detailsSection,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailsPanel(product: product),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            top: false,
            child: AppButton(
              text: ProductsStrings.editAction,
              onPressed: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.bodyMedium;
    final categoryName = product.category?.name;
    final createdAt = product.createdAt;

    final rows = <Widget>[
      if (categoryName != null)
        _InfoRow(
          label: ProductsStrings.categoryLabel,
          value: Text(categoryName, style: valueStyle),
        ),
      if (createdAt != null)
        _InfoRow(
          label: ProductsStrings.addedLabel,
          value: Text(ProductFormatters.date(createdAt), style: valueStyle),
        ),
      _InfoRow(
        label: ProductsStrings.visibilityLabel,
        value: ProductVisibilityBadge(isVisible: product.isVisible),
      ),
    ];

    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    // Expanded lets a long value wrap instead of overflowing the row
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerEnd, child: value),
        ),
      ],
    );
  }
}
