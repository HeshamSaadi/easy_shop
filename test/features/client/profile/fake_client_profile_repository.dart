import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

/// Hand-written fake. Every call succeeds unless a test sets a result, and
/// every call is recorded so a test can check what was sent.
class FakeClientProfileRepository implements ProfileRepository {
  Either<Failure, ClientEntity> profileResult = Right(buildClient());
  Either<Failure, ClientEntity> updateResult = Right(buildClient());

  int getCalls = 0;
  final List<
    ({
      String name,
      String email,
      String phone,
      String? address,
      double? latitude,
      double? longitude,
      String? picturePath,
    })
  >
  updateArgs = [];

  @override
  Future<Either<Failure, ClientEntity>> getProfile() async {
    getCalls++;
    return profileResult;
  }

  @override
  Future<Either<Failure, ClientEntity>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    updateArgs.add((
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    ));
    return updateResult;
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
