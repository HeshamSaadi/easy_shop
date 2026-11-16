import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/features/client/products/presentation/constants/product_details_strings.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_state.dart';
import 'package:flutter/material.dart';

class AddToCartBar extends StatelessWidget {
  const AddToCartBar({
    super.key,
    required this.inStock,
    required this.status,
    required this.onPressed,
  });

  final bool inStock;
  final AddToCartStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _button(),
      ),
    );
  }

  Widget _button() {
    if (!inStock) {
      return const AppButton(
        text: ProductDetailsStrings.outOfStock,
        onPressed: null,
      );
    }

    return switch (status) {
      AddToCartStatus.idle => AppButton(
        text: ProductDetailsStrings.addToCart,
        icon: Icons.shopping_cart_outlined,
        onPressed: onPressed,
      ),
      AddToCartStatus.adding => const AppButton(
        text: ProductDetailsStrings.addToCart,
        onPressed: null,
        isLoading: true,
      ),
      AddToCartStatus.added => const _AddedButton(),
    };
  }
}

class _AddedButton extends StatelessWidget {
  const _AddedButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: AppSizes.buttonHeight,
      ),
      child: ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: isDark
              ? AppColors.darkSuccessBackground
              : AppColors.successBackground,
          disabledForegroundColor: AppColors.success,
        ),
        icon: const Icon(Icons.check_circle_outline, size: AppSizes.iconSm),
        label: const Text(ProductDetailsStrings.added),
      ),
    );
  }
}
