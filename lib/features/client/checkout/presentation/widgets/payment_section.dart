import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:flutter/material.dart';

/// Cash is the only working method. Card is shown but disabled, because the
/// card flow was only tested up to the Paymob link (no browser package yet).
class PaymentSection extends StatelessWidget {
  const PaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      spacing: AppSpacing.md,
      children: [
        _PaymentOption(
          icon: Icons.payments_outlined,
          label: CheckoutStrings.cashOnDelivery,
          isSelected: true,
        ),
        _PaymentOption(
          icon: Icons.credit_card_outlined,
          label: CheckoutStrings.card,
          isEnabled: false,
          badge: CheckoutStrings.comingSoon,
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.isEnabled = true,
    this.badge,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isEnabled ? null : theme.mutedText;
    final badge = this.badge;

    return AppCard(
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconLg, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(color: color),
            ),
          ),
          if (badge != null)
            Text(
              badge,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.mutedText,
              ),
            )
          else if (isSelected)
            Icon(
              Icons.check_circle,
              size: AppSizes.iconLg,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
