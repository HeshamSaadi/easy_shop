import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension EditProfileFieldErrors on BuildContext {
  String? serverError(String field) =>
      read<EditProfileCubit>().state.fieldError(field);

  void clearServerError(String field) =>
      read<EditProfileCubit>().clearFieldError(field);
}
