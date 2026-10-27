import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/admin/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Either<Failure, Unit>> call(UpdateProfileParams params) =>
      _repository.updateProfile(params);
}
