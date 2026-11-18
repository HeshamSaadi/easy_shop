import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_item_entity.dart';
import 'package:easy_shop/features/client/orders/presentation/constants/client_orders_strings.dart';
import 'package:flutter/material.dart';

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item});

  static const double _imageSize = 48;

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox.square(
          dimension: _imageSize,
          child: AppNetworkImage(url: item.imageUrl),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                ClientOrdersStrings.itemLine(item.price, item.quantity),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.mutedText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          ClientOrdersStrings.money(item.totalPrice),
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
