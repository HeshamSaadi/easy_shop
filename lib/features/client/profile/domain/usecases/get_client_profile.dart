import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

/// Use case for retrieving the current client's profile.
///
/// Returns the authenticated client's full profile information
/// including personal details and delivery address if set.
class GetClientProfile {
  const GetClientProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, ClientEntity>> call() {
    return _repository.getProfile();
  }
}
