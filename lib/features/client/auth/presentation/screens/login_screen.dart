import 'package:easy_shop/core/widgets/app_logo.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/features/client/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Expects a [LoginCubit] above it (the router provides it).
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onOtpRequested,
    required this.onRegisterTap,
  });

  /// Called with the email after the server sent the OTP.
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

    return BlocConsumer<LoginCubit, LoginState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxxl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        AuthStrings.welcomeBack,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AuthStrings.loginSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).mutedText,
                        ),
                        textAlign: TextAlign.center,
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
                              AuthStrings.newUser,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).mutedText,
                              ),
                            ),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : widget.onRegisterTap,
                              child: Text(
                                AuthStrings.createAccount,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.clientPrimary,
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
