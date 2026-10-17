import 'package:easyshop/core/theme/app_sizes.dart';
import 'package:easyshop/core/theme/app_spacing.dart';
import 'package:easyshop/core/utils/app_strings.dart';
import 'package:easyshop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class AppError
    extends
        StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    required this.ontry,
  });
  final String message;
  final VoidCallback ontry;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(
      context,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXl,
              color: theme.colorScheme.error,
            ),
            const SizedBox(
              height: AppSpacing.lg,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(
              height: AppSpacing.xxl,
            ),
            AppButton(
              text: AppStrings.tryAgain,
              onPressed: ontry,
            ),
          ],
        ),
      ),
    );
  }
}
