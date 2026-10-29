import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/presentation/constants/orders_strings.dart';
import 'package:easy_shop/features/admin/orders/presentation/utils/order_formatters.dart';
import 'package:easy_shop/features/admin/orders/presentation/widgets/order_status_label.dart';
import 'package:flutter/material.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.md);
    final createdAt = order.createdAt;
    final itemsAndPayment =
        '${OrdersStrings.items(order.items.length)}  ·  '
        '${OrderFormatters.payment(order.paymentMethod)}';

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.code}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      order.client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        OrderFormatters.dateTime(createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PriceFormatter.format(order.totalPrice),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(itemsAndPayment, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  OrderStatusLabel(order: order),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
