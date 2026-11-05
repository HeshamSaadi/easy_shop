import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_avatar.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Expects a [RegisterCubit] above it (the router provides it).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onRegistered,
    required this.onLoginTap,
    required this.pickPicture,
  });

  final ValueChanged<String> onRegistered;
  final VoidCallback onLoginTap;
  final Future<String?> Function() pickPicture;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _picturePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    final path = await widget.pickPicture();
    if (path != null) {
      setState(() => _picturePath = path);
      if (mounted) {
        context.read<RegisterCubit>().clearFieldError('picture');
      }
    }
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<RegisterCubit>().register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      picturePath: _picturePath,
    );
  }

  void _onStatusChanged(BuildContext context, RegisterState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case RegisterStatus.success:
        messenger.showSnackBar(
          const SnackBar(content: Text(AuthStrings.accountCreated)),
        );
        widget.onRegistered(_emailController.text);
      case RegisterStatus.error:
        messenger.showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? ErrorMessages.unknown)),
        );
      case RegisterStatus.initial:
      case RegisterStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppTopBar(
            title: AuthStrings.createYourAccount,
            showBack: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AuthStrings.registerSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Profile Picture
                    Stack(
                      children: [
                        AppAvatar(
                          imageUrl: _picturePath,
                          size: 96,
                          backgroundColor: AppColors.clientPrimary.withValues(
                            alpha: 0.1,
                          ),
                          iconColor: AppColors.clientPrimary,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: isLoading ? null : _pickPicture,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.clientPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    AppTextField(
                      label: AuthStrings.fullName,
                      hint: AuthStrings.fullNameHint,
                      controller: _nameController,
                      validator: (value) => Validators.notEmpty(
                        value,
                        fieldName: AuthStrings.fullName,
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) =>
                          context.read<RegisterCubit>().clearFieldError('name'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.emailLabel,
                      hint: AuthStrings.emailHint,
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => context
                          .read<RegisterCubit>()
                          .clearFieldError('email'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.phoneNumber,
                      hint: AuthStrings.phoneHint,
                      controller: _phoneController,
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => context
                          .read<RegisterCubit>()
                          .clearFieldError('phone'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.passwordLabel,
                      hint: AuthStrings.createPasswordHint,
                      controller: _passwordController,
                      validator: Validators.password,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => context
                          .read<RegisterCubit>()
                          .clearFieldError('password'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.confirmPassword,
                      hint: AuthStrings.repeatPasswordHint,
                      controller: _confirmPasswordController,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onChanged: (_) => context
                          .read<RegisterCubit>()
                          .clearFieldError('password_confirmation'),
                    ),

                    if (state.fieldError('picture') != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.fieldError('picture')!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxxl),
                    AppButton(
                      text: AuthStrings.register,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          AuthStrings.alreadyHaveAccount,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : widget.onLoginTap,
                          child: Text(
                            AuthStrings.signInHere,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.clientPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
