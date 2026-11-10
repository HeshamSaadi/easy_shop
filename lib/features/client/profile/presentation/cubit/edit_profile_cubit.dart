import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:easy_shop/features/client/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required this._updateClientProfile})
    : super(const EditProfileState());

  final UpdateClientProfile _updateClientProfile;

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) return;
    final updated = Map<String, List<String>>.of(state.fieldErrors)
      ..remove(field);
    emit(state.copyWith(fieldErrors: updated));
  }

  void clearFieldErrors() {
    if (state.fieldErrors.isEmpty) return;
    emit(state.copyWith(fieldErrors: const {}));
  }

  Future<void> save({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    if (state.isSaving) return;

    emit(
      state.copyWith(status: EditProfileStatus.saving, fieldErrors: const {}),
    );

    final result = await _updateClientProfile(
      UpdateProfileParams(
        name: name.trim(),
        email: email.trim(),
        phone: PhoneUtils.toInternational(phone),
        address: _nullIfBlank(address),
        latitude: latitude,
        longitude: longitude,
        picturePath: picturePath,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: EditProfileStatus.error,
          fieldErrors: failure.fieldErrors,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: EditProfileStatus.success)),
    );
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
