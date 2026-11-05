import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

/// A titled block with a "See all" button. Shows [emptyText] when there are
/// no [children].
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.onSeeAll,
    required this.children,
  });

  final String title;
  final String emptyText;
  final VoidCallback onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(HomeStrings.seeAll),
            ),
          ],
        ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(emptyText, style: theme.textTheme.bodySmall),
          )
        else
          for (final child in children) ...[
            child,
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}
