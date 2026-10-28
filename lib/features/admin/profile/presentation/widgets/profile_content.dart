import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/info_row.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/info_section.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/profile_entity.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onLogout,
  });

  final ProfileEntity profile;
  final VoidCallback onEdit;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final address = profile.address;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: AppSpacing.xxl),
          InfoSection(
            title: ProfileStrings.personalInfo,
            rows: [
              InfoRow(label: ProfileStrings.fullName, value: profile.name),
              InfoRow(label: ProfileStrings.email, value: profile.email),
              InfoRow(label: ProfileStrings.phone, value: profile.phone),
              InfoRow(
                label: ProfileStrings.nationalId,
                value: profile.nationalId,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          InfoSection(
            title: ProfileStrings.businessInfo,
            rows: [
              InfoRow(
                label: ProfileStrings.businessName,
                value: profile.businessName,
              ),
              InfoRow(
                label: ProfileStrings.businessAddress,
                value: (address == null || address.isEmpty)
                    ? ProfileStrings.notSet
                    : address,
              ),
              InfoRow(
                label: ProfileStrings.storeLocation,
                value: profile.hasLocation
                    ? ProfileStrings.locationSet
                    : ProfileStrings.notSet,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          InfoSection(
            title: ProfileStrings.documents,
            rows: [
              _documentRow(
                ProfileStrings.commercialRegister,
                profile.hasCommercialRegister,
                colors,
              ),
              _documentRow(ProfileStrings.taxCard, profile.hasTaxCard, colors),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(text: ProfileStrings.editProfile, onPressed: onEdit),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: ProfileStrings.logout,
            isOutlined: true,
            onPressed: onLogout,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _documentRow(String label, bool uploaded, ColorScheme colors) {
    return InfoRow(
      label: label,
      value: uploaded ? ProfileStrings.uploaded : ProfileStrings.notUploaded,
      valueColor: uploaded ? colors.primary : colors.error,
    );
  }
}