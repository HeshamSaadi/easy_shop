import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/validators.dart';
import 'package:easy_shop/core/widgets/app_text_field.dart';
import 'package:easy_shop/core/widgets/picker_field.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_fields.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_controllers.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_field_errors.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditBusinessFields extends StatelessWidget {
  const EditBusinessFields({
    super.key,
    required this.controllers,
    required this.pickLocation,
  });

  final EditProfileControllers controllers;
  final PickStoreLocation pickLocation;

  Future<void> _pickLocation(BuildContext context) async {
    final cubit = context.read<EditProfileCubit>();
    final picked = await pickLocation(cubit.state.location);
    if (picked == null || !context.mounted) return;
    cubit.setLocation(latitude: picked.latitude, longitude: picked.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((EditProfileCubit c) => c.state.isLoading);
    final hasLocation = context.select(
      (EditProfileCubit c) => c.state.hasLocation,
    );
    final locationError = context.select(
      (EditProfileCubit c) =>
          c.state.fieldError(ProfileFields.latitude) ??
          c.state.fieldError(ProfileFields.longitude),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        AppTextField(
          label: ProfileStrings.businessName,
          controller: controllers.businessName,
          enabled: !isLoading,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              Validators.notEmpty(
                value,
                fieldName: ProfileStrings.businessName,
              ) ??
              context.serverError(ProfileFields.businessName),
          onChanged: (_) =>
              context.clearServerError(ProfileFields.businessName),
        ),
        AppTextField(
          label: ProfileStrings.businessAddress,
          hint: ProfileStrings.addressHint,
          controller: controllers.address,
          enabled: !isLoading,
          isOptional: true,
          textInputAction: TextInputAction.done,
          validator: (_) => context.serverError(ProfileFields.address),
          onChanged: (_) => context.clearServerError(ProfileFields.address),
        ),
        PickerField(
          label: ProfileStrings.storeLocation,
          placeholder: ProfileStrings.tapToSetLocation,
          icon: Icons.location_on_outlined,
          isOptional: true,
          value: hasLocation ? ProfileStrings.locationUpdate : null,
          errorText: locationError,
          onTap: isLoading ? null : () => _pickLocation(context),
        ),
      ],
    );
  }
}
