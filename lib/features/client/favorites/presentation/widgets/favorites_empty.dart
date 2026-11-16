import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/features/client/favorites/presentation/constants/favorites_strings.dart';
import 'package:flutter/material.dart';

/// "No favorites yet": a heart in a soft circle, a title and a hint.
class FavoritesEmpty extends StatelessWidget {
  const FavoritesEmpty({super.key});

  /// Diameter of the soft circle behind the heart.
  static const double _circle = 80;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _circle,
            height: _circle,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: AppOpacity.tint),
            ),
            child: Icon(
              Icons.favorite_border,
              size: AppSizes.iconLg,
              color: primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            FavoritesStrings.emptyTitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            FavoritesStrings.emptyMessage,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
