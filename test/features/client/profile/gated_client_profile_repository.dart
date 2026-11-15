import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

import 'fake_client_profile_repository.dart';

/// The shared fake, plus gates. A call is recorded first, then waits for its
/// gate, so a test can check what happens while a request is still running.
class GatedClientProfileRepository extends FakeClientProfileRepository {
  Completer<void>? getGate;
  Completer<void>? updateGate;

  @override
  Future<Either<Failure, ClientEntity>> getProfile() async {
    final result = await super.getProfile();
    await getGate?.future;
    return result;
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
    final result = await super.updateProfile(
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    );
    await updateGate?.future;
    return result;
  }
}
