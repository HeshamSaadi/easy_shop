import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/assets_path.dart'; // استيراد ملف المسارات
import 'package:flutter/material.dart';

/// Splash screen shown on app launch
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.clientPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                AssetsPath.logo,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'EasyShop',
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your Shopping Companion',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
