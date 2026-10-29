import 'package:easy_shop/features/admin/profile/domain/usecases/get_profile.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile) : super(const ProfileLoading());

  final GetProfile _getProfile;

  Future<void> load() async {
    if (state is! ProfileLoading) emit(const ProfileLoading());
    final result = await _getProfile();
    if (isClosed) return;
    emit(
      result.fold<ProfileState>(
        (failure) => ProfileError(failure.message),
        ProfileLoaded.new,
      ),
    );
  }
}
