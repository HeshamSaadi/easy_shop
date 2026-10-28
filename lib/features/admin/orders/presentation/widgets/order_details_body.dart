import 'package:easy_shop/core/location/location_viewer_screen.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/presentation/constants/orders_strings.dart';
import 'package:easy_shop/features/admin/orders/presentation/utils/order_formatters.dart';
import 'package:easy_shop/features/admin/orders/presentation/widgets/order_item_row.dart';
import 'package:easy_shop/features/admin/orders/presentation/widgets/order_status_label.dart';
import 'package:flutter/material.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(order: order),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            title: OrdersStrings.customerSection,
            child: _CustomerInfo(order: order),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: OrdersStrings.deliverySection,
            child: _DeliveryInfo(order: order),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: OrdersStrings.itemsSection,
            child: _ItemsList(order: order),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: OrdersStrings.paymentSection,
            child: Text(
              OrderFormatters.payment(order.paymentMethod),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: OrdersStrings.summarySection,
            child: _Summary(order: order),
          ),
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
        OrderStatusLabel(order: order),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  const _CustomerInfo({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final client = order.client;

    return Row(
      children: [
        _InitialsAvatar(name: client.name),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(client.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(client.email, style: theme.textTheme.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(client.phone, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  static const double _size = 44;
  static const int _maxLetters = 2;

  /// "Omar Hassan" -> "OH". Empty when the name has no letters.
  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(_maxLetters)
        .map((word) => word[0].toUpperCase())
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  const _DeliveryInfo({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final latitude = order.latitude;
    final longitude = order.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.address, style: Theme.of(context).textTheme.bodyMedium),
        if (latitude != null && longitude != null)
          TextButton.icon(
            onPressed: () => LocationViewerScreen.open(
              context,
              latitude: latitude,
              longitude: longitude,
              address: order.address,
            ),
            icon: const Icon(Icons.map_outlined),
            label: const Text(OrdersStrings.viewOnMap),
          ),
      ],
    );
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < order.items.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
          OrderItemRow(item: order.items[i]),
        ],
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(OrdersStrings.total, style: theme.textTheme.titleMedium),
        Text(
          PriceFormatter.format(order.totalPrice),
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
