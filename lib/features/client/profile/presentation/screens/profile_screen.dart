import 'package:easy_shop/core/theme/app_radius.dart';
import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/confirm_delete_dialog.dart';
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: ProfileStrings.logoutConfirmTitle,
      message: ProfileStrings.logoutConfirmMessage,
      confirmText: ProfileStrings.logout,
      cancelText: ProfileStrings.cancel,
    );
    if (confirmed) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: ProfileStrings.profile, showBack: false),
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
    final colors = theme.colorScheme;

    final address = client.address;
    final hasAddress = address != null && address.isNotEmpty;

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
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              iconColor: colors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              client.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              client.email,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
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
              value: hasAddress ? address : ProfileStrings.noAddressSet,
              isEmpty: !hasAddress,
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
                onPressed: () => _confirmLogout(context),
                icon: Icon(Icons.logout, color: colors.error),
                label: Text(
                  ProfileStrings.logout,
                  style: textTheme.labelLarge?.copyWith(color: colors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.error),
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

  static const double _iconBoxSize = 40;

  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: _iconBoxSize,
            height: _iconBoxSize,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: AppSizes.iconMd, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isEmpty ? colors.onSurfaceVariant : colors.onSurface,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
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
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(icon, size: AppSizes.iconMd, color: colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: AppSizes.iconMd,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
