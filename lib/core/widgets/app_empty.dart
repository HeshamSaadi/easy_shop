import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    required this.message,
    required this.icon,
    this.actionText,
    this.onAction,
  });
  final String message;
  final IconData icon;
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
            Icon(
              icon,
              size: AppSizes.iconXl,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
