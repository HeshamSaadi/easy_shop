import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:flutter/material.dart';

class RegisterStepHeader extends StatelessWidget {
  const RegisterStepHeader({super.key, required this.step});

  final RegisterStep step;

  String get _title => switch (step) {
    RegisterStep.personal => AuthStrings.stepPersonal,
    RegisterStep.business => AuthStrings.stepBusiness,
    RegisterStep.security => AuthStrings.stepSecurity,
  };

  @override
  Widget build(BuildContext context) {
    final total = RegisterStep.values.length;
    final current = step.index + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          AuthStrings.stepProgress(current, total, _title),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        LinearProgressIndicator(value: current / total),
      ],
    );
  }
}
