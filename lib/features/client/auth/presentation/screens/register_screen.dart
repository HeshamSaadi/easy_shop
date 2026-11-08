import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/picker_field.dart';
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
    required this.onPickLocation,
  });

  /// Called with the email after the server sent the OTP.
  final ValueChanged<String> onRegistered;
  final VoidCallback onLoginTap;
  final Future<PickedLocation?> Function() onPickLocation;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _coordinateDigits = 5;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  PickedLocation? _location;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? get _locationSummary {
    final location = _location;
    if (location == null) return null;
    final address = location.address;
    if (address != null && address.isNotEmpty) return address;
    final lat = location.latitude.toStringAsFixed(_coordinateDigits);
    final lng = location.longitude.toStringAsFixed(_coordinateDigits);
    return '$lat, $lng';
  }

  Future<void> _pickLocation() async {
    final picked = await widget.onPickLocation();
    if (picked == null || !mounted) return;

    setState(() => _location = picked);

    // Help the user: fill the address only if they did not type one.
    final resolvedAddress = picked.address;
    if (resolvedAddress != null && _addressController.text.trim().isEmpty) {
      _addressController.text = resolvedAddress;
    }
  }

  /// The server error for [field], read from the cubit so it is never stale.
  String? _serverError(String field) {
    return context.read<RegisterCubit>().state.fieldError(field);
  }

  FormFieldValidator<String> _withServerError(
    String field,
    FormFieldValidator<String> base,
  ) {
    return (value) => base(value) ?? _serverError(field);
  }

  void _clearError(String field) {
    context.read<RegisterCubit>().clearFieldError(field);
  }

  void _submit() {
    final cubit = context.read<RegisterCubit>();
    cubit.clearFieldErrors();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    cubit.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      address: _addressController.text,
      latitude: _location?.latitude,
      longitude: _location?.longitude,
    );
  }

  void _onStatusChanged(BuildContext context, RegisterState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case RegisterStatus.success:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(AuthStrings.accountCreated)),
          );
        widget.onRegistered(_emailController.text.trim());
      case RegisterStatus.error:
        if (state.fieldErrors.isEmpty) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? ErrorMessages.unknown),
              ),
            );
        } else {
          // Runs the validators again, so server errors show under the fields.
          _formKey.currentState?.validate();
        }
      case RegisterStatus.initial:
      case RegisterStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          appBar: const AppTopBar(
            title: AuthStrings.createAccount,
            showBack: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                // After the first interaction, errors update while typing.
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: AuthStrings.fullName,
                      hint: AuthStrings.fullNameHint,
                      controller: _nameController,
                      validator: _withServerError(
                        'name',
                        (value) => Validators.notEmpty(
                          value,
                          fieldName: AuthStrings.fullName,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('name'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.emailLabel,
                      hint: AuthStrings.emailHint,
                      controller: _emailController,
                      validator: _withServerError('email', Validators.email),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('email'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.phoneNumber,
                      hint: AuthStrings.phoneHint,
                      controller: _phoneController,
                      validator: _withServerError(
                        'phone',
                        Validators.egyptianPhone,
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('phone'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.addressLabel,
                      hint: AuthStrings.addressHint,
                      controller: _addressController,
                      validator: (_) => _serverError('address'),
                      textInputAction: TextInputAction.next,
                      isOptional: true,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('address'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PickerField(
                      label: AuthStrings.locationLabel,
                      placeholder: AuthStrings.locationHint,
                      icon: Icons.location_on_outlined,
                      value: _locationSummary,
                      isOptional: true,
                      onTap: isLoading ? null : _pickLocation,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.passwordLabel,
                      hint: AuthStrings.createPasswordHint,
                      controller: _passwordController,
                      validator: _withServerError(
                        'password',
                        Validators.password,
                      ),
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('password'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: AuthStrings.confirmPassword,
                      hint: AuthStrings.repeatPasswordHint,
                      controller: _confirmPasswordController,
                      validator: _withServerError(
                        'password_confirmation',
                        (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onChanged: (_) => _clearError('password_confirmation'),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AppButton(
                      text: AuthStrings.createAccount,
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
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading ? null : widget.onLoginTap,
                          child: Text(
                            AuthStrings.signInHere,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.primary,
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
