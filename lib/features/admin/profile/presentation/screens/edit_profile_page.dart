import 'package:easy_shop/core/location/location_picker_cubit.dart';
import 'package:easy_shop/core/location/location_picker_screen.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/core/utils/media_picker.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final _sl = GetIt.instance;

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key, required this.profile});

  final ProfileEntity profile;

  static Future<PickedLocation?> _pickLocation(
    BuildContext context,
    PickedLocation? initial,
  ) {
    return LocationPickerScreen.open(
      context,
      createCubit: () => _sl<LocationPickerCubit>(param1: initial),
    );
  }

  @override
  Widget build(BuildContext context) {
    final picker = _sl<MediaPicker>();
    return BlocProvider(
      create: (_) => _sl<EditProfileCubit>(param1: profile),
      child: EditProfileScreen(
        profile: profile,
        onSaved: () => context.pop(true),
        pickDocument: picker.pickDocument,
        pickPicture: picker.pickPicture,
        pickLocation: (initial) => _pickLocation(context, initial),
      ),
    );
  }
}
