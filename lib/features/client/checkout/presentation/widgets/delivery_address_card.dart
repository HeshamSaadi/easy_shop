import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/core/widgets/app_icon_badge.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:flutter/material.dart';

class DeliveryAddressCard extends StatelessWidget {
  const DeliveryAddressCard({
    super.key,
    required this.address,
    required this.hasLocation,
    required this.enabled,
    required this.onChange,
  });

  final String address;
  final bool hasLocation;

  /// False while the order is being placed.
  final bool enabled;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBadge(icon: Icons.location_on_outlined),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  hasLocation ? address : CheckoutStrings.noLocation,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: hasLocation ? null : theme.mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: hasLocation
                ? CheckoutStrings.changeLocation
                : CheckoutStrings.chooseLocation,
            icon: Icons.map_outlined,
            isOutlined: true,
            onPressed: enabled ? onChange : null,
          ),
        ],
      ),
    );
  }
}
