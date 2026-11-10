import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/assets_path.dart';
import 'package:easy_shop/core/widgets/app_loading_dots.dart';
import 'package:flutter/material.dart';

// White, used for the card and the texts on the brand-colored background.
const Color _onBrand = AppColors.surface;

/// Layout shared by the splash screens of both apps. Each app passes its own
/// brand color and texts.
class AppSplashView extends StatelessWidget {
  const AppSplashView({
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final Color backgroundColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _LogoCard(),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: textTheme.headlineMedium?.copyWith(color: _onBrand),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: _onBrand.withValues(alpha: AppOpacity.fadedText),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const AppLoadingDots(color: _onBrand),
          ],
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.logoCard,
      height: AppSizes.logoCard,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: AppOpacity.tint),
            blurRadius: AppSpacing.xxl,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Image.asset(AssetsPath.splashLogo, fit: BoxFit.contain),
    );
  }
}
