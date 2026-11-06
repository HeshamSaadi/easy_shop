import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final ProfileEntity profile;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}
