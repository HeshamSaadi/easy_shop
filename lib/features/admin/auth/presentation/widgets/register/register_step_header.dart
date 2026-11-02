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
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented Step Indicator Bars matching the design radius & thickness
        Row(
          children: List.generate(total, (index) {
            final isActive = index < current;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < total - 1 ? AppSpacing.sm : 0,
                ),
                height: 6, // سمك مناسب ومطابق للتصميم
                decoration: BoxDecoration(
                  color: isActive ? primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          AuthStrings.stepProgress(current, total, _title),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}