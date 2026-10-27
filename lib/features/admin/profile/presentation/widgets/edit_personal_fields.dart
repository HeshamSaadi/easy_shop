import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_fields.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_controllers.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_field_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPersonalFields extends StatelessWidget {
  const EditPersonalFields({super.key, required this.controllers});

  final EditProfileControllers controllers;

  @override
  Widget build(BuildContext context) {
    final enabled = !context.select((EditProfileCubit c) => c.state.isLoading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        AppTextField(
          label: ProfileStrings.fullName,
          controller: controllers.name,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.notEmpty(value, fieldName: ProfileStrings.fullName) ??
              context.serverError(ProfileFields.name),
          onChanged: (_) => context.clearServerError(ProfileFields.name),
        ),
        // Read-only: the email is the login identity (see A11 decision).
        AppTextField(
          label: ProfileStrings.email,
          controller: controllers.email,
          enabled: false,
        ),
        AppTextField(
          label: ProfileStrings.phone,
          controller: controllers.phone,
          enabled: enabled,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.egyptianPhone(value) ??
              context.serverError(ProfileFields.phone),
          onChanged: (_) => context.clearServerError(ProfileFields.phone),
        ),
        AppTextField(
          label: ProfileStrings.nationalId,
          controller: controllers.nationalId,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.nationalId(value) ??
              context.serverError(ProfileFields.nationalId),
          onChanged: (_) => context.clearServerError(ProfileFields.nationalId),
        ),
      ],
    );
  }
}
