import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';

/// The product image with a back button on top of it.
class DetailsImage extends StatelessWidget {
  const DetailsImage({super.key, required this.imageUrl, required this.onBack});

  /// Width divided by height of the image area.
  static const double _ratio = 1.1;

  final String imageUrl;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _ratio,
          child: AppNetworkImage(url: imageUrl, radius: 0),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IconButton.filled(
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                foregroundColor: colors.onSurface,
              ),
              icon: const Icon(Icons.arrow_back_ios_new, size: AppSizes.iconMd),
            ),
          ),
        ),
      ],
    );
  }
}
