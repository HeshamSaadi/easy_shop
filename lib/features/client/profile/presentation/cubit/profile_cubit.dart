import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._getClientProfile})
    : super(const ProfileInitial());

  final GetClientProfile _getClientProfile;

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
}
