import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/utils/assets_path.dart';
import 'package:flutter/material.dart';

/// The Easy Shop logo, for screens that show it on the plain background
/// (login, register). The splash screen uses its own white card instead.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppSizes.authLogo});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetsPath.splashLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
