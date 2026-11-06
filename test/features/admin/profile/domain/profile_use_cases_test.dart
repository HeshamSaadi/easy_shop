import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/get_profile.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/update_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fake_profile_repository.dart';

const _failure = Failure('No internet connection.');

const _params = UpdateProfileParams(
  name: 'Ahmed Khalil',
  email: 'ahmed@shop.com',
  phone: '+201001234567',
  nationalId: '29801234567890',
  businessName: 'Khalil Digital Store',
  address: '18 El Nasr Road',
  latitude: 30.0444,
  longitude: 31.2357,
  picturePath: '/tmp/photo.jpg',
);

void main() {
  late FakeProfileRepository repository;

  setUp(() {
    repository = FakeProfileRepository();
  });

  group('GetProfile', () {
    test('returns the profile from the repository', () async {
      final result = await GetProfile(repository)();

      expect(result, const Right(testProfile));
      expect(repository.getCalls, 1);
    });

    test('returns the failure unchanged', () async {
      repository.profileResult = const Left(_failure);

      final result = await GetProfile(repository)();

      expect(result, const Left<Failure, Object>(_failure));
    });
  });

  group('UpdateProfile', () {
    test('sends the params to the repository unchanged', () async {
      final result = await UpdateProfile(repository)(_params);

      expect(result, const Right<Failure, Unit>(unit));
      expect(repository.updateArgs.single, same(_params));
    });

    test('returns the failure unchanged', () async {
      repository.updateResult = const Left(_failure);

      final result = await UpdateProfile(repository)(_params);

      expect(result, const Left<Failure, Unit>(_failure));
    });
  });
}
