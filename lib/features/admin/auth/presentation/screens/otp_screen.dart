import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/otp_input.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/otp_screen_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/auth_strings.dart';
import '../cubit/otp_cubit.dart';
import '../cubit/otp_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';

  int _inputResetCount = 0;

  void _clearCode() {
    setState(() {
      _code = '';
      _inputResetCount++;
    });
  }

  void _showMessage(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _verify() {
    if (_code.length != OtpConfig.codeLength) {
      _showMessage(AuthStrings.enterFullCode);
      return;
    }
    context.read<OtpCubit>().verify(_code);
  }

  void _onStateChanged(BuildContext context, OtpState state) {
    switch (state.status) {
      case OtpStatus.verifyFailed:
        _showMessage(state.message);
        _clearCode();
      case OtpStatus.resendFailed:
        _showMessage(state.message);
      case OtpStatus.resendSuccess:
        _showMessage(AuthStrings.otpResent);
        _clearCode();
      case OtpStatus.verified:
      case OtpStatus.idle:
      case OtpStatus.verifying:
      case OtpStatus.resending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStateChanged,
      child: Scaffold(
        appBar: AppBar(title: const Text(AuthStrings.verifyEmail)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AuthStrings.checkYourEmail,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(AuthStrings.otpSentMessage, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxxl),
                OtpInput(
                  key: ValueKey(_inputResetCount),
                  length: OtpConfig.codeLength,
                  onChanged: (value) => _code = value,
                  onCompleted: (code) => context.read<OtpCubit>().verify(code),
                ),
                const SizedBox(height: AppSpacing.lg),
                BlocBuilder<OtpCubit, OtpState>(
                  builder: (context, state) => OtpScreenActions(
                    state: state,
                    onVerify: _verify,
                    onResend: context.read<OtpCubit>().resend,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
