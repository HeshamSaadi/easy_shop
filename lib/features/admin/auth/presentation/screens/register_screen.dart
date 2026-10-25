import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/business_step.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/personal_step.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_step_header.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/security_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({
    super.key,
    required this.onRegistered,
    required this.onExit,
    required this.pickDocument,
    required this.pickPicture,
    required this.pickLocation,
  });

  final VoidCallback onRegistered;
  final VoidCallback onExit;
  final PickFile pickDocument;
  final PickFile pickPicture;
  final PickLocation pickLocation;

  void _onStatusChanged(BuildContext context, RegisterState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case RegisterStatus.success:
        messenger.showSnackBar(
          const SnackBar(content: Text(AuthStrings.accountCreated)),
        );
        onRegistered();
      case RegisterStatus.error:
        messenger.showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? ErrorMessages.unknown)),
        );
      case RegisterStatus.initial:
      case RegisterStatus.loading:
        break;
    }
  }

  Widget _buildStep(RegisterStep step) {
    return switch (step) {
      RegisterStep.personal => const PersonalStep(),
      RegisterStep.business => BusinessStep(
        pickDocument: pickDocument,
        pickLocation: pickLocation,
      ),
      RegisterStep.security => SecurityStep(pickPicture: pickPicture),
    };
  }

  void _handleBack(RegisterCubit cubit) {
    if (cubit.state.step == RegisterStep.personal) {
      onExit();
    } else {
      cubit.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      buildWhen: (previous, current) => previous.step != current.step,
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(cubit);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text(AuthStrings.createAccount),
              leading: BackButton(onPressed: () => _handleBack(cubit)),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xxl,
                  children: [
                    RegisterStepHeader(step: state.step),
                    _buildStep(state.step),
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
