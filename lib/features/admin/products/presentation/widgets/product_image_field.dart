import 'dart:io';

import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_image.dart';
import 'package:flutter/material.dart';

/// Shows the newly picked file, else the current image, else a placeholder.
class ProductImageField extends StatelessWidget {
  const ProductImageField({
    super.key,
    required this.onTap,
    this.imagePath,
    this.imageUrl,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final String? imagePath;
  final String? imageUrl;
  final bool enabled;

  static const double _aspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(AppRadius.lg);
    final hasImage = imagePath != null || imageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: _aspectRatio,
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? onTap : null,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: _buildPreview(context),
              ),
            ),
          ),
        ),
        if (hasImage)
          TextButton.icon(
            onPressed: enabled ? onTap : null,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text(ProductsStrings.changeImage),
          ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final path = imagePath;
    final url = imageUrl;

    if (path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _Placeholder(),
        ),
      );
    }
    if (url != null) {
      return ProductImage(url: url, radius: AppRadius.lg);
    }
    return const _Placeholder();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(ProductsStrings.imageHint, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
