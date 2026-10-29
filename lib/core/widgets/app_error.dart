import 'package:easy_shop/core/utils/app_strings.dart';
import 'package:easy_shop/core/widgets/app_state_view.dart';
import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  const AppError({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppStateView(
      icon: Icons.error_outline,
      iconColor: Theme.of(context).colorScheme.error,
      message: message,
      actionText: AppStrings.tryAgain,
      onAction: onRetry,
    );
  }
}
