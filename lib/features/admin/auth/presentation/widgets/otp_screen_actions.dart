import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_state.dart';
import 'package:flutter/material.dart';

class OtpScreenActions extends StatelessWidget {
  const OtpScreenActions({
    super.key,
    required this.state,
    required this.onVerify,
    required this.onResend,
  });

  final OtpState state;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expiryText = state.isExpired
        ? AuthStrings.codeExpired
        : '${AuthStrings.codeExpiresIn}${_formatTime(state.secondsLeft)}';
    final resendText = state.resendCooldownLeft > 0
        ? '${AuthStrings.resendCode} (${state.resendCooldownLeft}s)'
        : AuthStrings.resendCode;

    return Column(
      children: [
        Text(
          expiryText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: state.isExpired ? theme.colorScheme.error : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          text: AuthStrings.verify,
          isLoading: state.status == OtpStatus.verifying,
          onPressed: state.canVerify ? onVerify : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextButton(
          onPressed: state.canResend ? onResend : null,
          child: Text(resendText),
        ),
      ],
    );
  }
}
