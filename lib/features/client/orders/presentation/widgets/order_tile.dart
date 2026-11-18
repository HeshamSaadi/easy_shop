import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/presentation/constants/client_orders_strings.dart';
import 'package:easy_shop/features/client/orders/presentation/widgets/order_status_label.dart';
import 'package:flutter/material.dart';

/// One order in the list: code, date, status, item count, payment and total.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.mutedText;
    final radius = BorderRadius.circular(AppRadius.md);
    final createdAt = order.createdAt;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.code}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  OrderStatusLabel(order: order),
                ],
              ),
              if (createdAt != null)
                Text(
                  ClientOrdersStrings.date(createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    ClientOrdersStrings.items(order.items.length),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    _paymentIcon(order.paymentMethod),
                    size: AppSizes.iconSm,
                    color: muted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    ClientOrdersStrings.payment(order.paymentMethod),
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  const Spacer(),
                  Text(
                    ClientOrdersStrings.money(order.totalPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _paymentIcon(PaymentMethod? method) {
    return switch (method) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card,
      null => Icons.account_balance_wallet_outlined,
    };
  }
}
