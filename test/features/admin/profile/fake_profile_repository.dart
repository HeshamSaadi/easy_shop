import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/admin/profile/domain/repositories/profile_repository.dart';

const testProfile = ProfileEntity(
  id: 7,
  name: 'Ahmed Khalil',
  email: 'ahmed@shop.com',
  phone: '+201001234567',
  nationalId: '29801234567890',
  businessName: 'Khalil Digital Store',
  pictureUrl: 'https://example.com/assets/images/default.png',
  hasCommercialRegister: true,
  hasTaxCard: false,
  address: '18 El Nasr Road',
  latitude: 30.0444,
  longitude: 31.2357,
);

/// Hand-written fake: set a result to choose the answer, read the
/// recorded values to check what was sent, and use a gate to keep a
/// call "in flight".
class FakeProfileRepository implements ProfileRepository {
  Either<Failure, ProfileEntity> profileResult = const Right(testProfile);
  Either<Failure, Unit> updateResult = const Right(unit);

  Completer<void>? getGate;
  Completer<void>? updateGate;

  int getCalls = 0;
  final List<UpdateProfileParams> updateArgs = [];

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    getCalls++;
    await getGate?.future;
    return profileResult;
  }

  @override
  Future<Either<Failure, Unit>> updateProfile(
    UpdateProfileParams params,
  ) async {
    updateArgs.add(params);
    await updateGate?.future;
    return updateResult;
  }
}
