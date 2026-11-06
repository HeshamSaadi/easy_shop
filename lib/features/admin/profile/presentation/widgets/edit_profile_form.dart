import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_button.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_state.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_business_field.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_document_fields.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_personal_fields.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_picture_field.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_controllers.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    super.key,
    required this.profile,
    required this.pickDocument,
    required this.pickPicture,
    required this.pickLocation,
  });

  final ProfileEntity profile;
  final PickFile pickDocument;
  final PickFile pickPicture;
  final PickStoreLocation pickLocation;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final EditProfileControllers _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = EditProfileControllers(widget.profile);
  }

  void _revalidate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _formKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EditProfileCubit>().submit(
      name: _controllers.name.text,
      phone: _controllers.phone.text,
      nationalId: _controllers.nationalId.text,
      businessName: _controllers.businessName.text,
      address: _controllers.address.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditProfileStatus.error,
      listener: (_, _) => _revalidate(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.lg,
            children: [
              EditPictureField(pickPicture: widget.pickPicture),
              EditPersonalFields(controllers: _controllers),
              EditBusinessFields(
                controllers: _controllers,
                pickLocation: widget.pickLocation,
              ),
              EditDocumentFields(
                profile: widget.profile,
                pickDocument: widget.pickDocument,
              ),
              BlocSelector<EditProfileCubit, EditProfileState, bool>(
                selector: (state) => state.isLoading,
                builder: (context, isLoading) => AppButton(
                  text: ProfileStrings.saveChanges,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
