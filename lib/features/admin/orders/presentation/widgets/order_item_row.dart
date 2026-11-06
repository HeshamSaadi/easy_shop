import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_item_entity.dart';
import 'package:easy_shop/features/admin/orders/presentation/utils/order_formatters.dart';
import 'package:flutter/material.dart';

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item});

  final OrderItemEntity item;

  static const double _imageSize = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = item.product.categoryName;

    return Row(
      children: [
        SizedBox.square(
          dimension: _imageSize,
          child: AppNetworkImage(url: item.product.imageUrl),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
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
                OrderFormatters.itemLine(item.price, item.quantity),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          PriceFormatter.format(item.totalPrice),
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
