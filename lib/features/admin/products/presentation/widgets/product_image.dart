import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

/// Fills the space its parent gives it (wrap it in a SizedBox or AspectRatio).
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.radius = AppRadius.sm,
  });

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            Center(child: Icon(Icons.image_outlined, color: color)),
      ),
    );
  }
}
