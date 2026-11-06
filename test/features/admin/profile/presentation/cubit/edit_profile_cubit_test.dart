import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/update_profile.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_profile_repository.dart';

Matcher _hasStatus(EditProfileStatus status) {
  return isA<EditProfileState>().having((s) => s.status, 'status', status);
}

void main() {
  late FakeProfileRepository repository;
  late EditProfileCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = EditProfileCubit(UpdateProfile(repository), testProfile);
  });

  tearDown(() => cubit.close());

  Future<void> submit({
    String name = 'Ahmed Khalil',
    String phone = '1013114901',
    String nationalId = '29801234567890',
    String businessName = 'Khalil Digital Store',
    String address = '18 El Nasr Road',
  }) {
    return cubit.submit(
      name: name,
      phone: phone,
      nationalId: nationalId,
      businessName: businessName,
      address: address,
    );
  }

  group('initial state', () {
    test('starts idle with the location of the profile', () {
      expect(cubit.state.status, EditProfileStatus.initial);
      expect(cubit.state.latitude, testProfile.latitude);
      expect(cubit.state.longitude, testProfile.longitude);
      expect(cubit.state.hasLocation, isTrue);
      expect(cubit.state.picturePath, isNull);
    });
  });

  group('setters', () {
    test('setPicture, setCommercialRegister and setTaxCard keep the paths', () {
      cubit.setPicture('/tmp/photo.jpg');
      cubit.setCommercialRegister('/tmp/register.jpg');
      cubit.setTaxCard('/tmp/tax.jpg');

      expect(cubit.state.picturePath, '/tmp/photo.jpg');
      expect(cubit.state.commercialRegisterPath, '/tmp/register.jpg');
      expect(cubit.state.taxCardPath, '/tmp/tax.jpg');
    });

    test('setLocation replaces the saved location', () {
      cubit.setLocation(latitude: 31.2, longitude: 29.9);

      expect(cubit.state.latitude, 31.2);
      expect(cubit.state.longitude, 29.9);
    });
  });

  group('submit', () {
    test('emits loading then success', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          _hasStatus(EditProfileStatus.loading),
          _hasStatus(EditProfileStatus.success),
        ]),
      );

      await submit();
      await expectation;
    });

    test(
      'sends trimmed text, the profile email and an international phone',
      () async {
        await submit(
          name: '  Ahmed K  ',
          nationalId: ' 29801234567890 ',
          businessName: ' My Store ',
          address: ' Cairo ',
        );

        final sent = repository.updateArgs.single;
        expect(sent.name, 'Ahmed K');
        expect(sent.email, testProfile.email);
        expect(sent.phone, '+201013114901');
        expect(sent.nationalId, '29801234567890');
        expect(sent.businessName, 'My Store');
        expect(sent.address, 'Cairo');
      },
    );

    test('sends the chosen location and the picked files', () async {
      cubit.setLocation(latitude: 31.2, longitude: 29.9);
      cubit.setPicture('/tmp/photo.jpg');
      cubit.setCommercialRegister('/tmp/register.jpg');
      cubit.setTaxCard('/tmp/tax.jpg');

      await submit();

      final sent = repository.updateArgs.single;
      expect(sent.latitude, 31.2);
      expect(sent.longitude, 29.9);
      expect(sent.picturePath, '/tmp/photo.jpg');
      expect(sent.commercialRegisterPath, '/tmp/register.jpg');
      expect(sent.taxCardPath, '/tmp/tax.jpg');
    });

    test('sends no file paths when the user picked none', () async {
      await submit();

      final sent = repository.updateArgs.single;
      expect(sent.picturePath, isNull);
      expect(sent.commercialRegisterPath, isNull);
      expect(sent.taxCardPath, isNull);
    });

    test('emits error with the message and the errors of each field', () async {
      repository.updateResult = const Left(
        Failure(
          'The phone field format is invalid.',
          statusCode: 422,
          fieldErrors: {
            'phone': ['The phone field format is invalid.'],
          },
        ),
      );

      await submit();

      expect(cubit.state.status, EditProfileStatus.error);
      expect(cubit.state.errorMessage, 'The phone field format is invalid.');
      expect(
        cubit.state.fieldError('phone'),
        'The phone field format is invalid.',
      );
      expect(cubit.state.fieldError('name'), isNull);
    });

    test('a new submit clears the old field errors', () async {
      repository.updateResult = const Left(
        Failure(
          'Invalid',
          fieldErrors: {
            'phone': ['Invalid phone'],
          },
        ),
      );
      await submit();
      expect(cubit.state.fieldError('phone'), isNotNull);

      repository.updateResult = const Right(unit);
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<EditProfileState>()
              .having((s) => s.status, 'status', EditProfileStatus.loading)
              .having((s) => s.fieldErrors, 'fieldErrors', isEmpty),
          _hasStatus(EditProfileStatus.success),
        ]),
      );

      await submit();
      await expectation;
    });

    test('ignores a second submit while the first one is loading', () async {
      final gate = Completer<void>();
      repository.updateGate = gate;

      final first = submit();
      await submit();
      gate.complete();
      await first;

      expect(repository.updateArgs, hasLength(1));
    });

    test('does not emit a result after the cubit is closed', () async {
      final gate = Completer<void>();
      repository.updateGate = gate;
      final states = <EditProfileState>[];
      cubit.stream.listen(states.add);

      final running = submit();
      await cubit.close();
      gate.complete();
      await running;

      expect(
        states.where((s) => s.status != EditProfileStatus.loading),
        isEmpty,
      );
    });
  });

  group('clearFieldError', () {
    Future<void> failWithTwoFieldErrors() async {
      repository.updateResult = const Left(
        Failure(
          'Invalid',
          fieldErrors: {
            'phone': ['Invalid phone'],
            'name': ['Name is required'],
          },
        ),
      );
      await submit();
    }

    test('removes only the field that was named', () async {
      await failWithTwoFieldErrors();

      cubit.clearFieldError('phone');

      expect(cubit.state.fieldError('phone'), isNull);
      expect(cubit.state.fieldError('name'), 'Name is required');
    });

    test('emits nothing when the field has no error', () async {
      await failWithTwoFieldErrors();
      final states = <EditProfileState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.clearFieldError('email');
      await Future<void>.delayed(Duration.zero);

      expect(states, isEmpty);
      await subscription.cancel();
    });
  });
}
