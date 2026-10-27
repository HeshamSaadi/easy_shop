import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/admin/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/admin/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() {
    return guardedCall(() async => (await _remote.getProfile()).toEntity());
  }

  @override
  Future<Either<Failure, Unit>> updateProfile(UpdateProfileParams params) {
    return guardedUnitCall(() => _remote.updateProfile(params));
  }
}
