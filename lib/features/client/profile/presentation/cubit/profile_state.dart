import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

/// Initial state before loading profile.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profile is being loaded from the server.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully.
final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.client);

  final ClientEntity client;
}

/// Error occurred while loading profile.
final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}
