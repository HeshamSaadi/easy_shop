import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.client);

  final ClientEntity client;
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}
