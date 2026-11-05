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

/// Profile is being updated.
final class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Profile updated successfully.
final class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.client);

  final ClientEntity client;
}

/// Error occurred while updating profile.
final class ProfileUpdateError extends ProfileState {
  const ProfileUpdateError(this.message, [this.fieldErrors]);

  final String message;
  final Map<String, List<String>>? fieldErrors;

  String? fieldError(String fieldName) {
    final errors = fieldErrors?[fieldName];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }
}
