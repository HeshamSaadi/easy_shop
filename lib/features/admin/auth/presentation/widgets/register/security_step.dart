import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_fields.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/picker_field.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_pickers.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_step_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecurityStep extends StatefulWidget {
  const SecurityStep({super.key, required this.pickPicture});

  final PickFile pickPicture;

  @override
  State<SecurityStep> createState() => _SecurityStepState();
}

class _SecurityStepState extends State<SecurityStep>
    with ServerFieldErrors<SecurityStep> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickPicture() async {
    final cubit = context.read<RegisterCubit>();
    final path = await widget.pickPicture();
    if (path == null || !mounted) return;
    cubit.setPicture(path);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RegisterCubit>().submit(
      password: _password.text,
      passwordConfirmation: _confirmPassword.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) =>
          previous.draft != current.draft ||
          previous.fieldErrors != current.fieldErrors ||
          previous.status != current.status,
      builder: (context, state) {
        final isLoading = state.isLoading;
        return RegisterStepForm(
          formKey: _formKey,
          children: [
            Text(
              AuthStrings.headingSecurity,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            PickerField.file(
              label: AuthStrings.profilePicture,
              placeholder: AuthStrings.uploadPhoto,
              icon: Icons.add_a_photo_outlined,
              isOptional: true,
              filePath: state.draft.picturePath,
              errorText: state.fieldError(RegisterFields.picture),
              onTap: isLoading ? null : _pickPicture,
            ),
            AppTextField(
              label: AuthStrings.password,
              hint: AuthStrings.createPasswordHint,
              controller: _password,
              isPassword: true,
              enabled: !isLoading,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  Validators.password(value) ??
                  serverError(RegisterFields.password),
              onChanged: (_) => clearServerError(RegisterFields.password),
            ),
            AppTextField(
              label: AuthStrings.confirmPassword,
              hint: AuthStrings.repeatPasswordHint,
              controller: _confirmPassword,
              isPassword: true,
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
              validator: (value) =>
                  Validators.confirmPassword(value, _password.text),
            ),
            AppButton(
              text: AuthStrings.createAccount,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        );
      },
    );
  }
}
