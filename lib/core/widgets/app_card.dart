import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The bordered surface shared by every card in the admin app.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = AppSpacing.lg});

  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: child,
    );
  }
}
