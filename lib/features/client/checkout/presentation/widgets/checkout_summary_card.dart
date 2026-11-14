import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:flutter/material.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.itemCount,
    required this.total,
  });

  final int itemCount;
  final double total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          _SummaryRow(
            label: CheckoutStrings.itemsLabel(itemCount),
            value: CheckoutStrings.money(total),
          ),
          _SummaryRow(
            label: CheckoutStrings.total,
            value: CheckoutStrings.money(total),
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
