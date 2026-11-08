import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/otp_input.dart';
import 'package:easy_shop/features/client/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _otpLength = 6;

  String _code = '';

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
        _clearInput();
        _showMessage(context, state.message ?? ErrorMessages.unknown);
      case OtpStatus.resendFailed:
        _showMessage(context, state.message ?? ErrorMessages.unknown);
      case OtpStatus.idle:
      case OtpStatus.verifying:
      case OtpStatus.resending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final email = context.read<OtpCubit>().email;

    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      // The countdown has its own widget, so ticks do not rebuild this one.
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isExpired != current.isExpired,
      builder: (context, state) {
        final canVerify =
            _code.length == _otpLength && !state.isExpired && !state.isBusy;

        return Scaffold(
          appBar: const AppTopBar(
            title: AuthStrings.verifyOtpTitle,
            showBack: true,
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AuthStrings.codeSentTo} $email',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    OtpInput(
                      key: _inputKey,
                      length: _otpLength,
                      onChanged: (value) => setState(() => _code = value),
                      onCompleted: (code) =>
                          context.read<OtpCubit>().verify(code),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _CountdownLabel(),
                    const SizedBox(height: AppSpacing.xxxl),
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

/// Shows the time left. Rebuilds every tick, so it is kept small.
class _CountdownLabel extends StatelessWidget {
  const _CountdownLabel();

  static String _format(Duration remaining) {
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
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<OtpCubit, OtpState>(
      buildWhen: (previous, current) => previous.remaining != current.remaining,
      builder: (context, state) {
        return Text(
          state.isExpired
              ? AuthStrings.codeExpired
              : '${AuthStrings.codeExpiresIn} ${_format(state.remaining)}',
          style: textTheme.bodyMedium?.copyWith(
            color: state.isExpired ? colors.error : colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
