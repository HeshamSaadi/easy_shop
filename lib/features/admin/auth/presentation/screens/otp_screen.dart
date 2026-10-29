import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/otp_input.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Expects an [OtpCubit] above it (the router provides it and calls `start()`).
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.onVerified});

  /// Called after the code was accepted and the token was saved.
  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  String _code = '';

  // A new key rebuilds OtpInput, which clears its boxes.
  Key _inputKey = UniqueKey();

  void _submit() {
    if (_code.length != _otpLength) return;
    context.read<OtpCubit>().verify(_code);
  }

  void _clearInput() {
    setState(() {
      _code = '';
      _inputKey = UniqueKey();
    });
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onStatusChanged(BuildContext context, OtpState state) {
    switch (state.status) {
      case OtpStatus.verified:
        widget.onVerified();
      case OtpStatus.resent:
        _clearInput();
        _showMessage(context, AuthStrings.otpResent);
      case OtpStatus.verifyFailed:
      case OtpStatus.resendFailed:
        _showMessage(context, state.message ?? ErrorMessages.unknown);
      case OtpStatus.idle:
      case OtpStatus.verifying:
      case OtpStatus.resending:
        break;
    }
  }

  String _formatRemaining(Duration remaining) {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = remaining.inSeconds
        .remainder(Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      builder: (context, state) {
        final canVerify =
            _code.length == _otpLength && !state.isExpired && !state.isBusy;

        return Scaffold(
          appBar: const AppTopBar(
            title: AuthStrings.verifyEmail,
            showBack: true,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AuthStrings.checkYourEmail,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AuthStrings.otpSubtitle,
                      style: textTheme.bodyMedium?.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    Center(
                      child: OtpInput(
                        key: _inputKey,
                        length: _otpLength,
                        onChanged: (value) => setState(() => _code = value),
                        onCompleted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: Text(
                        state.isExpired
                            ? AuthStrings.codeExpired
                            : '${AuthStrings.codeExpiresIn} '
                                  '${_formatRemaining(state.remaining)}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: state.isExpired ? errorColor : mutedColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      text: AuthStrings.verify,
                      isLoading: state.status == OtpStatus.verifying,
                      onPressed: canVerify ? _submit : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      text: AuthStrings.resendCode,
                      isOutlined: true,
                      isLoading: state.status == OtpStatus.resending,
                      onPressed: state.isBusy
                          ? null
                          : () => context.read<OtpCubit>().resend(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
