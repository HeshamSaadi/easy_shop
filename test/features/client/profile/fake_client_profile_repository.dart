import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

/// Hand-written fake. Only `getProfile` is used by checkout, so
/// `updateProfile` is not needed and throws if something calls it.
class FakeClientProfileRepository implements ProfileRepository {
  Either<Failure, ClientEntity> profileResult = Right(buildClient());

  @override
  Future<Either<Failure, ClientEntity>> getProfile() async => profileResult;

  @override
  Future<Either<Failure, ClientEntity>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) {
    throw UnimplementedError();
  }
}

ClientEntity buildClient({
  String? address = '123 Tahrir Square, Cairo',
  double? latitude = 30.0444,
  double? longitude = 31.2357,
}) {
  return ClientEntity(
    id: 1,
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phone: '+201000000000',
    address: address,
    latitude: latitude,
    longitude: longitude,
  );
}
