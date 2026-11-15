import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_client_profile_repository.dart';
import '../../gated_client_profile_repository.dart';

Matcher _hasStatus(EditProfileStatus status) {
  return isA<EditProfileState>().having((s) => s.status, 'status', status);
}

const _validationFailure = Failure(
  'Validation failed',
  statusCode: 422,
  fieldErrors: {
    'email': ['The email has already been taken.'],
    'phone': ['The phone field format is invalid.'],
  },
);

void main() {
  late GatedClientProfileRepository repository;
  late EditProfileCubit cubit;

  Future<void> save({
    String name = 'Ahmed Hassan',
    String email = 'ahmed@example.com',
    String phone = '01013114901',
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) {
    return cubit.save(
      name: name,
      email: email,
      phone: phone,
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    );
  }

  setUp(() {
    repository = GatedClientProfileRepository();
    cubit = EditProfileCubit(
      updateClientProfile: UpdateClientProfile(repository),
    );
  });

  tearDown(() => cubit.close());

  test('starts in the initial state with no errors', () {
    expect(cubit.state.status, EditProfileStatus.initial);
    expect(cubit.state.fieldErrors, isEmpty);
    expect(cubit.state.errorMessage, isNull);
  });

  test('success emits saving, then success', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        _hasStatus(EditProfileStatus.saving),
        _hasStatus(EditProfileStatus.success),
      ]),
    );

    await save();
    await expectation;
  });

  test('trims the name and the email', () async {
    await save(name: '  Ahmed Hassan ', email: ' ahmed@example.com ');

    final sent = repository.updateArgs.single;
    expect(sent.name, 'Ahmed Hassan');
    expect(sent.email, 'ahmed@example.com');
  });

  test('sends the phone in the international format', () async {
    for (final input in ['01013114901', '1013114901', '+20 101 311 4901']) {
      await save(phone: input);
    }

    expect(
      repository.updateArgs.map((a) => a.phone),
      everyElement('+201013114901'),
    );
  });

  test('a blank address becomes null, a typed one is trimmed', () async {
    await save(address: '   ');
    await save(address: '  123 Tahrir Square ');

    expect(repository.updateArgs[0].address, isNull);
    expect(repository.updateArgs[1].address, '123 Tahrir Square');
  });

  test('passes the coordinates and the picture path through', () async {
    await save(
      latitude: 30.0444,
      longitude: 31.2357,
      picturePath: '/tmp/photo.jpg',
    );
    await save();

    expect(repository.updateArgs[0].latitude, 30.0444);
    expect(repository.updateArgs[0].longitude, 31.2357);
    expect(repository.updateArgs[0].picturePath, '/tmp/photo.jpg');
    expect(repository.updateArgs[1].latitude, isNull);
    expect(repository.updateArgs[1].longitude, isNull);
    expect(repository.updateArgs[1].picturePath, isNull);
  });

  test('a 422 keeps the errors of each field and the message', () async {
    repository.updateResult = const Left(_validationFailure);

    await save();

    expect(cubit.state.status, EditProfileStatus.error);
    expect(cubit.state.errorMessage, 'Validation failed');
    expect(
      cubit.state.fieldError('email'),
      'The email has already been taken.',
    );
    expect(
      cubit.state.fieldError('phone'),
      'The phone field format is invalid.',
    );
    expect(cubit.state.fieldError('name'), isNull);
  });

  test('a new save clears the old field errors while saving', () async {
    repository.updateResult = const Left(_validationFailure);
    await save();
    expect(cubit.state.fieldErrors, isNotEmpty);

    repository.updateResult = Right(buildClient());
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<EditProfileState>()
            .having((s) => s.status, 'status', EditProfileStatus.saving)
            .having((s) => s.fieldErrors, 'fieldErrors', isEmpty),
        _hasStatus(EditProfileStatus.success),
      ]),
    );

    await save();
    await expectation;
  });

  test('clearFieldError removes only that field', () async {
    repository.updateResult = const Left(_validationFailure);
    await save();

    cubit.clearFieldError('email');

    expect(cubit.state.fieldError('email'), isNull);
    expect(
      cubit.state.fieldError('phone'),
      'The phone field format is invalid.',
    );
  });

  test('clearFieldError does nothing for a field without an error', () async {
    repository.updateResult = const Left(_validationFailure);
    await save();
    final before = cubit.state;

    cubit.clearFieldError('name');

    expect(identical(cubit.state, before), isTrue);
  });

  test('clearFieldErrors removes every field error', () async {
    repository.updateResult = const Left(_validationFailure);
    await save();

    cubit.clearFieldErrors();

    expect(cubit.state.fieldErrors, isEmpty);
  });

  test('ignores a second save while the first is running', () async {
    final gate = Completer<void>();
    repository.updateGate = gate;

    final first = save();
    await save();
    gate.complete();
    await first;

    expect(repository.updateArgs, hasLength(1));
  });

  group('EditProfileState.fieldError', () {
    test('returns the first message of a field', () {
      const state = EditProfileState(
        fieldErrors: {
          'email': ['first', 'second'],
        },
      );

      expect(state.fieldError('email'), 'first');
    });

    test('returns null for a missing or empty field', () {
      const state = EditProfileState(fieldErrors: {'email': []});

      expect(state.fieldError('email'), isNull);
      expect(state.fieldError('phone'), isNull);
    });
  });
}
