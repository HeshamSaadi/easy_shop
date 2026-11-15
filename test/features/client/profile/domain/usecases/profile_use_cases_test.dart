import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/params/update_profile_params.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_client_profile_repository.dart';

const _failure = Failure('No internet connection.');

void main() {
  late FakeClientProfileRepository repository;

  setUp(() {
    repository = FakeClientProfileRepository();
  });

  group('GetClientProfile', () {
    test('asks the repository once and returns the client', () async {
      final result = await GetClientProfile(repository)();

      expect(repository.getCalls, 1);
      expect(result.isRight(), isTrue);
      expect(result.fold((_) => null, (c) => c.name), 'Ahmed Hassan');
    });

    test('returns the failure unchanged', () async {
      repository.profileResult = const Left(_failure);

      final result = await GetClientProfile(repository)();

      expect(result.fold((f) => f, (_) => null), same(_failure));
    });
  });

  group('UpdateClientProfile', () {
    test('passes every field to the repository', () async {
      await UpdateClientProfile(repository)(
        const UpdateProfileParams(
          name: 'Ahmed',
          email: 'ahmed@example.com',
          phone: '+201013114901',
          address: '123 Tahrir Square',
          latitude: 30.0444,
          longitude: 31.2357,
          picturePath: '/tmp/photo.jpg',
        ),
      );

      final sent = repository.updateArgs.single;
      expect(sent.name, 'Ahmed');
      expect(sent.email, 'ahmed@example.com');
      expect(sent.phone, '+201013114901');
      expect(sent.address, '123 Tahrir Square');
      expect(sent.latitude, 30.0444);
      expect(sent.longitude, 31.2357);
      expect(sent.picturePath, '/tmp/photo.jpg');
    });

    test('keeps the optional fields null when they are not given', () async {
      await UpdateClientProfile(repository)(
        const UpdateProfileParams(
          name: 'Ahmed',
          email: 'ahmed@example.com',
          phone: '+201013114901',
        ),
      );

      final sent = repository.updateArgs.single;
      expect(sent.address, isNull);
      expect(sent.latitude, isNull);
      expect(sent.longitude, isNull);
      expect(sent.picturePath, isNull);
    });

    test('returns the failure unchanged', () async {
      repository.updateResult = const Left(_failure);

      final result = await UpdateClientProfile(repository)(
        const UpdateProfileParams(
          name: 'Ahmed',
          email: 'ahmed@example.com',
          phone: '+201013114901',
        ),
      );

      expect(result.fold((f) => f, (_) => null), same(_failure));
    });
  });
}
