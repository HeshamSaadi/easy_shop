import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/update_profile.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_state.dart';
import 'package:easy_shop/core/utils/phone_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._updateProfile, ProfileEntity profile)
    : _profile = profile,
      super(
        EditProfileState(
          latitude: profile.latitude,
          longitude: profile.longitude,
        ),
      );

  final UpdateProfile _updateProfile;
  final ProfileEntity _profile;

  void setPicture(String path) => emit(state.copyWith(picturePath: path));

  void setCommercialRegister(String path) =>
      emit(state.copyWith(commercialRegisterPath: path));

  void setTaxCard(String path) => emit(state.copyWith(taxCardPath: path));

  void setLocation({required double latitude, required double longitude}) =>
      emit(state.copyWith(latitude: latitude, longitude: longitude));

  void clearFieldError(String field) {
    if (!state.fieldErrors.containsKey(field)) return;
    emit(state.copyWith(fieldErrors: Map.of(state.fieldErrors)..remove(field)));
  }

  Future<void> submit({
    required String name,
    required String phone,
    required String nationalId,
    required String businessName,
    required String address,
  }) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: EditProfileStatus.loading, fieldErrors: const {}),
    );

    final result = await _updateProfile(
      UpdateProfileParams(
        name: name.trim(),
        email: _profile.email, // read-only, but required by the server
        phone: PhoneUtils.toInternational(phone),
        nationalId: nationalId.trim(),
        businessName: businessName.trim(),
        address: address.trim(),
        latitude: state.latitude,
        longitude: state.longitude,
        picturePath: state.picturePath,
        commercialRegisterPath: state.commercialRegisterPath,
        taxCardPath: state.taxCardPath,
      ),
    );
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: EditProfileStatus.error,
          errorMessage: failure.message,
          fieldErrors: failure.fieldErrors,
        ),
        (_) => state.copyWith(status: EditProfileStatus.success),
      ),
    );
  }
}
