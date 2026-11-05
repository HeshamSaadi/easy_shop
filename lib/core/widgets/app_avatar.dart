import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.backgroundColor,
    this.iconColor,
    this.size = AppSizes.avatarMd,
  });

  final String? imageUrl;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      // The icon stays behind the photo, so it shows while the photo loads
      // or if it fails to load.
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Icon(Icons.person_outline, size: size / 2, color: iconColor),
    );
  }
}
