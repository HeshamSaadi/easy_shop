import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pictureUrl = profile.pictureUrl;

    return Column(
      spacing: AppSpacing.sm,
      children: [
        CircleAvatar(
          radius: ProfileSizes.avatarRadius,
          foregroundImage: pictureUrl.isEmpty ? null : NetworkImage(pictureUrl),
          onForegroundImageError: (_, _) {},
          child: const Icon(Icons.person_outline),
        ),
        Text(profile.name, style: theme.textTheme.titleLarge),
        Text(profile.businessName, style: theme.textTheme.bodyMedium),
        Text(profile.email, style: theme.textTheme.bodySmall),
        const Chip(label: Text(ProfileStrings.merchant)),
      ],
    );
  }
}
