import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/features/admin/auth/presentation/constants/auth_strings.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_fields.dart';
import 'package:easy_shop/features/admin/auth/presentation/widgets/register/register_step_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalStep extends StatefulWidget {
  const PersonalStep({super.key});

  @override
  State<PersonalStep> createState() => _PersonalStepState();
}

class _PersonalStepState extends State<PersonalStep>
    with ServerFieldErrors<PersonalStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _nationalId;

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegisterCubit>().state.draft;
    _name = TextEditingController(text: draft.name);
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: PhoneUtils.toLocal(draft.phone));
    _nationalId = TextEditingController(text: draft.nationalId);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _nationalId.dispose();
    super.dispose();
  }

  void _continue() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RegisterCubit>().savePersonal(
      name: _name.text,
      email: _email.text,
      phone: PhoneUtils.toInternational(_phone.text),
      nationalId: _nationalId.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegisterStepForm(
      formKey: _formKey,
      children: [
        Text(
          AuthStrings.headingPersonal,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppTextField(
          label: AuthStrings.fullName,
          hint: AuthStrings.fullNameHint,
          controller: _name,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.notEmpty(value, fieldName: AuthStrings.fullName) ??
              serverError(RegisterFields.name),
          onChanged: (_) => clearServerError(RegisterFields.name),
        ),
        AppTextField(
          label: AuthStrings.emailLabel,
          hint: AuthStrings.emailHint,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.email(value) ?? serverError(RegisterFields.email),
          onChanged: (_) => clearServerError(RegisterFields.email),
        ),
        AppTextField(
          label: AuthStrings.phoneNumber,
          hint: AuthStrings.phoneHint,
          controller: _phone,
          prefixText: '${PhoneUtils.egyptCode} ',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) =>
              Validators.egyptianPhone(value) ??
              serverError(RegisterFields.phone),
          onChanged: (_) => clearServerError(RegisterFields.phone),
        ),
        AppTextField(
          label: AuthStrings.nationalId,
          hint: AuthStrings.nationalIdHint,
          controller: _nationalId,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) =>
              Validators.nationalId(value) ??
              serverError(RegisterFields.nationalId),
          onChanged: (_) => clearServerError(RegisterFields.nationalId),
        ),
        AppButton(text: AuthStrings.continueLabel, onPressed: _continue),
      ],
    );
  }
}
