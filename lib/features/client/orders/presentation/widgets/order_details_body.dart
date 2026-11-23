import 'package:easy_shop/core/location/location_viewer_screen.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/core/widgets/app_icon_badge.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/presentation/constants/client_orders_strings.dart';
import 'package:easy_shop/features/client/orders/presentation/widgets/order_item_row.dart';
import 'package:easy_shop/features/client/orders/presentation/widgets/order_status_label.dart';
import 'package:flutter/material.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        spacing: AppSpacing.md,
        children: [
          _Header(order: order),
          _AddressCard(order: order),
          _ItemsCard(order: order),
          _PaymentCard(method: order.paymentMethod),
          _SummaryCard(order: order),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = order.createdAt;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('#${order.code}', style: theme.textTheme.titleLarge),
              if (createdAt != null)
                Text(
                  ClientOrdersStrings.dateTime(createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.mutedText,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        OrderStatusLabel(order: order),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latitude = order.latitude;
    final longitude = order.longitude;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ClientOrdersStrings.deliveryAddress,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const AppIconBadge(icon: Icons.location_on_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(order.address, style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
          if (latitude != null && longitude != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: ClientOrdersStrings.viewOnMap,
              icon: Icons.map_outlined,
              isOutlined: true,
              onPressed: () => LocationViewerScreen.open(
                context,
                latitude: latitude,
                longitude: longitude,
                address: order.address,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.md,
        children: [
          Text(
            ClientOrdersStrings.orderItems,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final item in order.items) OrderItemRow(item: item),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.method});

  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = method == PaymentMethod.card
        ? Icons.credit_card
        : Icons.payments_outlined;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ClientOrdersStrings.paymentMethod,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: theme.mutedText),
              const SizedBox(width: AppSpacing.sm),
              Text(
                ClientOrdersStrings.payment(method),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Text(
            ClientOrdersStrings.orderSummary,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: ClientOrdersStrings.itemsLabel(order.items.length),
            value: ClientOrdersStrings.money(order.totalPrice),
          ),
          _SummaryRow(
            label: ClientOrdersStrings.total,
            value: ClientOrdersStrings.money(order.totalPrice),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = isBold ? textTheme.titleMedium : textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
