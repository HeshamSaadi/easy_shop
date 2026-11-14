import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:flutter/material.dart';

class CheckoutItemsCard extends StatelessWidget {
  const CheckoutItemsCard({super.key, required this.items});

  final List<CartItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        spacing: AppSpacing.md,
        children: [for (final item in items) _ItemRow(item: item)],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: theme.textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                CheckoutStrings.quantity(item.quantity),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.mutedText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          CheckoutStrings.money(item.lineTotal),
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
