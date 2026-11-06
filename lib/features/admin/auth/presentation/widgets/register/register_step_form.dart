import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin ServerFieldErrors<T extends StatefulWidget> on State<T> {
  String? serverError(String field) =>
      context.read<RegisterCubit>().state.fieldError(field);

  void clearServerError(String field) =>
      context.read<RegisterCubit>().clearFieldError(field);
}

class RegisterStepForm extends StatefulWidget {
  const RegisterStepForm({
    super.key,
    required this.formKey,
    required this.children,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  State<RegisterStepForm> createState() => _RegisterStepFormState();
}

class _RegisterStepFormState extends State<RegisterStepForm> {
  @override
  void initState() {
    super.initState();
    if (context.read<RegisterCubit>().state.fieldErrors.isNotEmpty) {
      _revalidate();
    }
  }

  void _revalidate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.formKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == RegisterStatus.error,
      listener: (_, _) => _revalidate(),
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: widget.children,
        ),
      ),
    );
  }
}
