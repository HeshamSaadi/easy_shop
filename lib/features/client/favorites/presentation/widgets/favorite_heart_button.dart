import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/features/client/favorites/presentation/constants/favorites_strings.dart';
import 'package:flutter/material.dart';

/// Round heart button on top of an image. Filled when the product is a
/// favorite. It is disabled while a request for the product is in flight.
class FavoriteHeartButton extends StatelessWidget {
  const FavoriteHeartButton({
    super.key,
    required this.isFavorite,
    required this.isBusy,
    required this.onPressed,
    this.compact = false,
  });

  final bool isFavorite;
  final bool isBusy;
  final VoidCallback onPressed;

  /// Smaller button for the product cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton.filled(
      onPressed: isBusy ? null : onPressed,
      tooltip: isFavorite ? FavoritesStrings.remove : FavoritesStrings.add,
      visualDensity: compact ? VisualDensity.compact : null,
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: isFavorite ? colors.primary : colors.onSurface,
        disabledBackgroundColor: colors.surface,
      ),
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: compact ? AppSizes.iconSm : AppSizes.iconMd,
      ),
    );
  }
}
