import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/features/client/checkout/presentation/constants/checkout_strings.dart';
import 'package:flutter/material.dart';

/// Shown after an order is placed. It only shows a result, so it has no
/// Cubit: the navigation is passed in as callbacks.
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.orderCode,
    required this.onViewOrders,
    required this.onContinueShopping,
  });

  static const double _iconSize = 96;

  final String orderCode;
  final VoidCallback onViewOrders;
  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: _iconSize,
                          color: AppColors.clientPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          CheckoutStrings.successTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          CheckoutStrings.successMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.mutedText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          '#$orderCode',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppButton(
                text: CheckoutStrings.viewOrders,
                onPressed: onViewOrders,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: CheckoutStrings.continueShopping,
                isOutlined: true,
                onPressed: onContinueShopping,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
