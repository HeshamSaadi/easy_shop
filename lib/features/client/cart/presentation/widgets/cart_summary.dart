import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/client/cart/presentation/constants/cart_strings.dart';
import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.itemCount,
    required this.total,
    required this.hasProblems,
    required this.onCheckout,
  });

  final int itemCount;
  final double total;
  final bool hasProblems;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  CartStrings.itemCount(itemCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _SummaryRow(
                label: CartStrings.subtotal,
                value: CartStrings.money(total),
              ),
              const SizedBox(height: AppSpacing.xs),
              _SummaryRow(
                label: CartStrings.total,
                value: CartStrings.money(total),
                isBold: true,
              ),
              if (hasProblems) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CartStrings.fixItems,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: CartStrings.checkout,
                onPressed: hasProblems ? null : onCheckout,
              ),
            ],
          ),
        ),
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
