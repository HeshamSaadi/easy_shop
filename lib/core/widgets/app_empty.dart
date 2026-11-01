import 'package:easy_shop/core/widgets/app_state_view.dart';
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
    return AppStateView(
      icon: icon,
      iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
      message: message,
      actionText: actionText,
      onAction: onAction,
    );
  }
}
