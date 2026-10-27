import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_state.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/profile_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onEdit,
    required this.onLogout,
  });

  final Future<bool?> Function(ProfileEntity profile) onEdit;
  final VoidCallback onLogout;

  Future<void> _edit(BuildContext context, ProfileEntity profile) async {
    final cubit = context.read<ProfileCubit>();
    final changed = await onEdit(profile);
    if (changed == true) await cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.title)),
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => switch (state) {
            ProfileLoading() => const AppLoading(),
            ProfileError(:final message) => AppError(
              message: message,
              onRetry: cubit.load,
            ),
            ProfileLoaded(:final profile) => ProfileContent(
              profile: profile,
              onEdit: () => _edit(context, profile),
              onLogout: onLogout,
            ),
          },
        ),
      ),
    );
  }
}
