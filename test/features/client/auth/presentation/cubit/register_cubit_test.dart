import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/register_client.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../gated_client_auth_repository.dart';

Matcher _hasStatus(RegisterStatus status) {
  return isA<RegisterState>().having((s) => s.status, 'status', status);
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
  late GatedClientAuthRepository repository;
  late RegisterCubit cubit;

  Future<void> register({
    String name = 'Ahmed Hassan',
    String email = 'ahmed@example.com',
    String phone = '01013114901',
    String password = '12345678',
    String? address,
    double? latitude,
    double? longitude,
  }) {
    return cubit.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: password,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  setUp(() {
    repository = GatedClientAuthRepository();
    cubit = RegisterCubit(registerClient: RegisterClient(repository));
  });

  tearDown(() => cubit.close());

  test('starts in the initial state with no errors', () {
    expect(cubit.state.status, RegisterStatus.initial);
    expect(cubit.state.fieldErrors, isEmpty);
    expect(cubit.state.errorMessage, isNull);
  });

  test('success emits loading, then success', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        _hasStatus(RegisterStatus.loading),
        _hasStatus(RegisterStatus.success),
      ]),
    );

    await register();
    await expectation;
  });

  test(
    'trims the name and the email and keeps the password as typed',
    () async {
      await register(
        name: '  Ahmed Hassan ',
        email: ' ahmed@example.com ',
        password: ' 1234 5678 ',
      );

      final sent = repository.registerArgs.single;
      expect(sent.name, 'Ahmed Hassan');
      expect(sent.email, 'ahmed@example.com');
      expect(sent.password, ' 1234 5678 ');
      expect(sent.passwordConfirmation, ' 1234 5678 ');
    },
  );

  test('sends the phone in the international format', () async {
    for (final input in ['01013114901', '1013114901', '+20 101 311 4901']) {
      await register(phone: input);
    }

    expect(
      repository.registerArgs.map((p) => p.phone),
      everyElement('+201013114901'),
    );
  });

  test('a blank address becomes null, a typed one is trimmed', () async {
    await register(address: '   ');
    await register(address: '  123 Tahrir Square ');

    expect(repository.registerArgs[0].address, isNull);
    expect(repository.registerArgs[1].address, '123 Tahrir Square');
  });

  test(
    'passes the coordinates through, and null when there are none',
    () async {
      await register(latitude: 30.0444, longitude: 31.2357);
      await register();

      expect(repository.registerArgs[0].latitude, 30.0444);
      expect(repository.registerArgs[0].longitude, 31.2357);
      expect(repository.registerArgs[1].latitude, isNull);
      expect(repository.registerArgs[1].longitude, isNull);
    },
  );

  test('a 422 keeps the errors of each field and the message', () async {
    repository.registerResult = const Left(_validationFailure);

    await register();

    expect(cubit.state.status, RegisterStatus.error);
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

  test('a new submit clears the old field errors while loading', () async {
    repository.registerResult = const Left(_validationFailure);
    await register();
    expect(cubit.state.fieldErrors, isNotEmpty);

    repository.registerResult = const Right(unit);
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.loading)
            .having((s) => s.fieldErrors, 'fieldErrors', isEmpty),
        _hasStatus(RegisterStatus.success),
      ]),
    );

    await register();
    await expectation;
  });

  test('clearFieldError removes only that field', () async {
    repository.registerResult = const Left(_validationFailure);
    await register();

    cubit.clearFieldError('email');

    expect(cubit.state.fieldError('email'), isNull);
    expect(
      cubit.state.fieldError('phone'),
      'The phone field format is invalid.',
    );
  });

  test('clearFieldError does nothing for a field without an error', () async {
    repository.registerResult = const Left(_validationFailure);
    await register();
    final before = cubit.state;

    cubit.clearFieldError('name');

    expect(identical(cubit.state, before), isTrue);
  });

  test('clearFieldErrors removes every field error', () async {
    repository.registerResult = const Left(_validationFailure);
    await register();

    cubit.clearFieldErrors();

    expect(cubit.state.fieldErrors, isEmpty);
  });

  test('ignores a second register while the first is running', () async {
    final gate = Completer<void>();
    repository.registerGate = gate;

    final first = register();
    await register();
    gate.complete();
    await first;

    expect(repository.registerArgs, hasLength(1));
  });

  group('RegisterState.fieldError', () {
    test('returns the first message of a field', () {
      const state = RegisterState(
        fieldErrors: {
          'email': ['first', 'second'],
        },
      );

      expect(state.fieldError('email'), 'first');
    });

    test('returns null for a missing or empty field', () {
      const state = RegisterState(fieldErrors: {'email': []});

      expect(state.fieldError('email'), isNull);
      expect(state.fieldError('phone'), isNull);
    });
  });
}
