import 'package:easyshop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:easyshop/core/theme/app_spacing.dart';

/// Main button used across both apps.
/// Shows a loader and blocks taps while [isLoading] is true.
class AppButton
    extends
        StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  @override
  Widget build(
    BuildContext context,
  ) {
    // null disables the button, so a second tap does nothing while loading
    final VoidCallback? action = isLoading
        ? null
        : onPressed;
    final Widget child = _buildChild(
      context,
    );

    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: action,
              child: child,
            )
          : ElevatedButton(
              onPressed: action,
              child: child,
            ),
    );
  }

  Widget _buildChild(
    BuildContext context,
  ) {
    final colors = Theme.of(
      context,
    ).colorScheme;

    if (isLoading) {
      return SizedBox(
        width: AppSizes.loaderSm,
        height: AppSizes.loaderSm,
        child: CircularProgressIndicator(
          strokeWidth: AppSizes.loaderStroke,
          color: isOutlined
              ? colors.primary
              : colors.onPrimary,
        ),
      );
    }

    if (icon ==
        null) {
      return Text(
        text,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppSizes.iconSm,
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
