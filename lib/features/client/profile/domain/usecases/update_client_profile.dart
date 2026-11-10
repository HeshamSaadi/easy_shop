import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

/// Use case for updating the current client's profile.
///
/// Updates client information including personal details,
/// delivery address, and profile picture.
class UpdateClientProfile {
  const UpdateClientProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ClientEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      name: params.name,
      email: params.email,
      phone: params.phone,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      picturePath: params.picturePath,
    );
  }
}
