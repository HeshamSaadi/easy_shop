import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_state.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_form.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.onSaved,
    required this.pickDocument,
    required this.pickPicture,
    required this.pickLocation,
  });

  final ProfileEntity profile;
  final VoidCallback onSaved;
  final PickFile pickDocument;
  final PickFile pickPicture;
  final PickStoreLocation pickLocation;

  void _onStatusChanged(BuildContext context, EditProfileState state) {
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case EditProfileStatus.success:
        messenger.showSnackBar(
          const SnackBar(content: Text(ProfileStrings.profileUpdated)),
        );
        onSaved();
      case EditProfileStatus.error:
        messenger.showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? ErrorMessages.unknown)),
        );
      case EditProfileStatus.initial:
      case EditProfileStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onStatusChanged,
      child: Scaffold(
        appBar: AppBar(title: const Text(ProfileStrings.editTitle)),
        body: SafeArea(
          child: EditProfileForm(
            profile: profile,
            pickDocument: pickDocument,
            pickPicture: pickPicture,
            pickLocation: pickLocation,
          ),
        ),
      ),
    );
  }
}
