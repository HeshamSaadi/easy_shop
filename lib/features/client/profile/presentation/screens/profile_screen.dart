import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/core/widgets/app_icon_badge.dart';
import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_opacity.dart';
import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/presentation/constants/profile_strings.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onLogout,
    required this.onEditProfile,
    required this.onMyOrders,
    required this.onFavorites,
  });

  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback onMyOrders;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(ProfileStrings.profile),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() => const SizedBox.shrink(),
            ProfileLoading() => const AppLoading(),
            ProfileLoaded(:final client) => _buildProfileContent(
              context,
              client,
            ),
            ProfileError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            ),
          };
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ClientEntity client) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final address = client.address;
    final addressText = (address == null || address.isEmpty) ? null : address;

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header with Avatar
            AppAvatar(
              imageUrl: client.pictureUrl,
              size: AppSizes.avatarLg,
              backgroundColor: AppColors.clientPrimary.withValues(
                alpha: AppOpacity.tint,
              ),
              iconColor: AppColors.clientPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              client.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              client.email,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).mutedText,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Information Cards
            _InfoCard(
              icon: Icons.phone_outlined,
              label: ProfileStrings.phone,
              value: client.phone,
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoCard(
              icon: Icons.location_on_outlined,
              label: ProfileStrings.address,
              value: addressText ?? ProfileStrings.noAddressSet,
              isEmpty: addressText == null,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Action Buttons
            _ActionButton(
              icon: Icons.receipt_long_outlined,
              label: ProfileStrings.myOrders,
              onTap: onMyOrders,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.favorite_outline,
              label: ProfileStrings.favorites,
              onTap: onFavorites,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: ProfileStrings.editProfile,
              onTap: onEditProfile,
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  ProfileStrings.logout,
                  style: textTheme.labelLarge?.copyWith(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppCard(
      child: Row(
        children: [
          AppIconBadge(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isEmpty
                        ? theme.mutedText
                        : theme.colorScheme.onSurface,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: AppColors.clientPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppSizes.iconMd,
                color: Theme.of(context).mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
