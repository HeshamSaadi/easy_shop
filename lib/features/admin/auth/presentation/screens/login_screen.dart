import 'package:easy_shop/apps/admin/admin_route_names.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/auth_strings.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      context.pushNamed(AdminRouteNames.otp, extra: state.email);
    } else if (state is LoginError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Text(AuthStrings.forBusiness, style: textTheme.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(AuthStrings.welcomeBack, style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(AuthStrings.loginSubtitle, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  controller: _emailController,
                  label: AuthStrings.email,
                  hint: AuthStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _passwordController,
                  label: AuthStrings.password,
                  hint: AuthStrings.passwordHint,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.notEmpty(
                    value,
                    fieldName: AuthStrings.password,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                BlocConsumer<LoginCubit, LoginState>(
                  listener: _onStateChanged,
                  builder: (context, state) => AppButton(
                    text: AuthStrings.signIn,
                    isLoading: state is LoginLoading,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(AdminRouteNames.register),
                    child: const Text(
                      '${AuthStrings.newMerchant}${AuthStrings.createMerchantAccount}',
                    ),
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
