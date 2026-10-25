import 'package:easy_shop/apps/admin/admin_shell.dart';
import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Temporary Profile tab until A11. It only offers Logout.
class ProfilePlaceholderScreen extends StatelessWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AdminShellStrings.profile)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                text: AdminShellStrings.logout,
                isOutlined: true,
                onPressed: () => context.read<SessionCubit>().logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
