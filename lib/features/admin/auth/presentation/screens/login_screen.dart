import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onOtpRequested,
    required this.onRegisterTap,
  });

  final ValueChanged<String> onOtpRequested;
  final VoidCallback onRegisterTap;

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
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    context.read<LoginCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state is LoginSuccess) {
      widget.onOtpRequested(state.email);
    } else if (state is LoginFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AuthStrings.forBusiness,
                        style: textTheme.bodySmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AuthStrings.welcomeBack,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AuthStrings.loginSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      AppTextField(
                        label: AuthStrings.emailLabel,
                        hint: AuthStrings.emailHint,
                        controller: _emailController,
                        validator: Validators.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: AuthStrings.passwordLabel,
                        hint: AuthStrings.passwordHint,
                        controller: _passwordController,
                        validator: (value) => Validators.notEmpty(
                          value,
                          fieldName: AuthStrings.passwordLabel,
                        ),
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        text: AuthStrings.signIn,
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              AuthStrings.newMerchant,
                              style: textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : widget.onRegisterTap,
                              child: Text(
                                AuthStrings.createMerchantAccount,
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}