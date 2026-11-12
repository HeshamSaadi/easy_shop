import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/presentation/constants/cart_strings.dart';
import 'package:easy_shop/features/client/cart/presentation/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.isBusy,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  static const double _imageSize = 72;

  final CartItemEntity item;
  final bool isBusy;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  /// The server accepts hidden products and quantities above the stock,
  /// so the tile tells the user instead of hiding the problem.
  String? get _warning {
    if (item.isHidden) return CartStrings.unavailable;
    if (!item.exceedsStock) return null;
    return item.product.stock == 0
        ? CartStrings.outOfStock
        : CartStrings.stockLimit(item.product.stock);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;
    final warning = _warning;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _imageSize,
            height: _imageSize,
            child: AppNetworkImage(url: product.imageUrl),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.categoryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.mutedText,
                  ),
                ),
                Text(
                  product.name,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CartStrings.money(product.price),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (warning != null)
                  Text(
                    warning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    QuantityStepper(
                      quantity: item.quantity,
                      maxQuantity: product.stock,
                      isBusy: isBusy,
                      onIncrease: onIncrease,
                      onDecrease: onDecrease,
                    ),
                    const Spacer(),
                    Text(
                      CartStrings.money(item.lineTotal),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isBusy ? null : onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline,
              size: AppSizes.iconLg,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
