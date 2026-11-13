import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    this.client = const ClientEntity(
      id: 1,
      name: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phone: '+201001234567',
    ),
  });

  final ClientEntity client;

  @override
  Future<Either<Failure, ClientEntity>> getProfile() async => Right(client);

  @override
  Future<Either<Failure, ClientEntity>> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async => Right(client);
}
