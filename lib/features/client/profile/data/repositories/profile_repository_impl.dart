import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ClientEntity>> getProfile() async {
    try {
      final client = await _remoteDataSource.getProfile();
      return Right(client);
    } on AppException catch (e) {
      return Left(Failure(e.message, fieldErrors: e.fieldErrors));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? latitude,
    String? longitude,
    String? picturePath,
  }) async {
    try {
      final client = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        picturePath: picturePath,
      );
      return Right(client);
    } on AppException catch (e) {
      return Left(Failure(e.message, fieldErrors: e.fieldErrors));
    }
  }
}
