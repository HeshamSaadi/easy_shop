import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Centered icon, message and an optional button. AppEmpty and AppError
/// are built on it. Scrollable, so it never overflows in landscape or
/// with a large font.
class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.message,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAction = actionText != null && onAction != null;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconXl, color: iconColor),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (hasAction) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton(text: actionText!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
