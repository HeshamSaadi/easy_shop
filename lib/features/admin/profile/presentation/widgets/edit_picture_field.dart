// lib/features/admin/profile/presentation/widgets/edit_picture_field.dart
import 'package:easy_shop/core/widgets/picker_field.dart';
import 'package:easy_shop/features/admin/profile/constants/profile_strings.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/widgets/edit_profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPictureField extends StatelessWidget {
  const EditPictureField({super.key, required this.pickPicture});

  final PickFile pickPicture;

  Future<void> _pick(BuildContext context) async {
    final cubit = context.read<EditProfileCubit>();
    final path = await pickPicture();
    if (path == null || !context.mounted) return;
    cubit.setPicture(path);
  }

  @override
  Widget build(BuildContext context) {
    final path = context.select((EditProfileCubit c) => c.state.picturePath);
    final isLoading = context.select((EditProfileCubit c) => c.state.isLoading);

    return PickerField.file(
      label: ProfileStrings.profilePicture,
      placeholder: ProfileStrings.changePhoto,
      icon: Icons.add_a_photo_outlined,
      isOptional: true,
      filePath: path,
      onTap: isLoading ? null : () => _pick(context),
    );
  }
}
