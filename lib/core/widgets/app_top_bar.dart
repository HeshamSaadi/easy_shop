import 'package:easyshop/core/theme/app_sizes.dart';
import 'package:easyshop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class AppTopBar
    extends
        StatelessWidget
    implements
        PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.showBack,
    this.onBack,
    this.actionIcon,
    this.onAction,
  });
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Size get preferredSize => const Size.fromHeight(
    kToolbarHeight,
  );
  @override
  Widget build(
    BuildContext context,
  ) {
    final textTheme = Theme.of(
      context,
    ).textTheme;

    final hasAction =
        actionIcon !=
            null &&
        onAction !=
            null;

    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: textTheme.titleMedium,
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: AppSizes.iconMd,
              ),
              onPressed:
                  onBack ??
                  () => Navigator.maybePop(
                    context,
                  ),
            )
          : null,
      actions: [
        if (hasAction)
          Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.lg,
            ),
            child: IconButton.filled(
              onPressed: onAction,
              icon: Icon(
                actionIcon,
              ),
            ),
          ),
      ],
    );
  }
}
