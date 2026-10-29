import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final pictureUrl = profile.pictureUrl;

    return Column(
      children: [
        AppAvatar(
          imageUrl: pictureUrl.isEmpty ? null : pictureUrl,
          backgroundColor: primary.withValues(alpha: 0.1),
          iconColor: primary,
          size: AppSizes.avatarLg,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.businessName,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.xxl),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xs,
            ),
          ),
          child: Text(
            ProfileStrings.merchant,
            style: theme.textTheme.labelLarge?.copyWith(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
