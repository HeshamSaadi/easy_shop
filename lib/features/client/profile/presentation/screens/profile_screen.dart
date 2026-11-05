import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
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
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileInitial() => const SizedBox.shrink(),
            ProfileLoading() || ProfileUpdating() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProfileLoaded(client: final client) ||
            ProfileUpdateSuccess(
              client: final client,
            ) => _buildProfileContent(context, client),
            ProfileError(message: final message) ||
            ProfileUpdateError(message: final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message.isNotEmpty ? message : ErrorMessages.unknown,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ClientEntity client) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().loadProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Profile Header
            _ProfileHeader(client: client),

            const SizedBox(height: AppSpacing.xl),

            // Personal Information Section
            _InfoSection(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _InfoTile(
                  icon: Icons.person,
                  label: 'Name',
                  value: client.name,
                ),
                _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: client.email,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: client.phone,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Delivery Address Section
            _InfoSection(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              children: [
                if (client.address != null && client.address!.isNotEmpty)
                  _InfoTile(
                    icon: Icons.home_outlined,
                    label: 'Address',
                    value: client.address!,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No delivery address set',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Quick Links
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('My Orders'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onMyOrders,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: const Text('Favorites'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onFavorites,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: client.pictureUrl != null
                  ? NetworkImage(client.pictureUrl!)
                  : null,
              child: client.pictureUrl == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              client.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              client.email,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
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
