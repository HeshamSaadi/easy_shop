import 'package:easy_shop/features/client/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetClientProfile getClientProfile,
    required UpdateClientProfile updateClientProfile,
  }) : _getClientProfile = getClientProfile,
       _updateClientProfile = updateClientProfile,
       super(const ProfileInitial());

  final GetClientProfile _getClientProfile;
  final UpdateClientProfile _updateClientProfile;

  /// Loads the current client's profile from the server.
  Future<void> loadProfile() async {
    if (state is ProfileLoading) return;

    emit(const ProfileLoading());

    final result = await _getClientProfile();

    if (isClosed) return;

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (client) => emit(ProfileLoaded(client)),
    );
  }

  /// Updates the current client's profile.
  Future<void> updateProfile(UpdateProfileParams params) async {
    if (state is ProfileUpdating) return;

    emit(const ProfileUpdating());

    final result = await _updateClientProfile(params);

    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(ProfileUpdateError(failure.message, failure.fieldErrors)),
      (client) => emit(ProfileUpdateSuccess(client)),
    );
  }

  /// Clears field-specific error for a given field name.
  void clearFieldError(String fieldName) {
    if (state is ProfileUpdateError) {
      final currentState = state as ProfileUpdateError;
      final updatedErrors = Map<String, List<String>>.from(
        currentState.fieldErrors ?? {},
      )..remove(fieldName);

      emit(ProfileUpdateError(currentState.message, updatedErrors));
    }
  }
}
