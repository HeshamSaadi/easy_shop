import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/jwt_helper.dart';
import '../../fake_auth_data_sources.dart';

const _email = 'client@shop.com';
const _password = '12345678';
const _success = Right<Failure, Unit>(unit);

Failure _failureOf(Either<Failure, Unit> result) {
  return result.fold((failure) => failure, (_) => fail('Expected a failure'));
}

void main() {
  late List<String> log;
  late FakeClientAuthRemoteDataSource remote;
  late FakeTokenStorage storage;
  late RecordingSessionEvents sessionEvents;
  late AuthRepositoryImpl repository;

  setUp(() {
    log = [];
    remote = FakeClientAuthRemoteDataSource(log);
    storage = FakeTokenStorage(log);
    sessionEvents = RecordingSessionEvents(log);
    repository = AuthRepositoryImpl(remote, storage, sessionEvents);
  });

  tearDown(() => sessionEvents.dispose());

  group('login', () {
    test('forwards the credentials and returns unit', () async {
      final result = await repository.login(email: _email, password: _password);

      expect(result, _success);
      expect(remote.loginArgs, [(email: _email, password: _password)]);
    });

    test('returns the server message and status code on a 401', () async {
      remote.error = const UnauthorizedException('Invalid email or password');

      final result = await repository.login(email: _email, password: 'wrong');

      final failure = _failureOf(result);
      expect(failure.message, 'Invalid email or password');
      expect(failure.statusCode, 401);
    });

    test('returns the friendly message when there is no internet', () async {
      remote.error = const NoInternetException();

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.noInternet);
    });

    test('returns the friendly message on a timeout', () async {
      remote.error = const ConnectionTimeoutException();

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.timeout);
    });

    test('returns the friendly message on a server error', () async {
      remote.error = const ServerException(statusCode: 500);

      final result = await repository.login(email: _email, password: _password);

      final failure = _failureOf(result);
      expect(failure.message, ErrorMessages.server);
      expect(failure.statusCode, 500);
    });

    test('turns an unexpected error into the unknown message', () async {
      remote.error = StateError('boom');

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.unknown);
    });
  });

  group('register', () {
    test('returns unit when the server accepts the account', () async {
      final result = await repository.register(
        name: 'Ahmed Hassan',
        email: 'ahmed@example.com',
        phone: '+201013114901',
        password: _password,
        passwordConfirmation: _password,
      );

      expect(result, _success);
      expect(remote.registerArgs.length, 1);
      expect(remote.registerArgs.first.name, 'Ahmed Hassan');
      expect(remote.registerArgs.first.email, 'ahmed@example.com');
    });

    test('keeps the errors of each field on a 422', () async {
      remote.error = const BadRequestException(
        'The email has already been taken.',
        statusCode: 422,
        fieldErrors: {
          'email': ['The email has already been taken.'],
        },
      );

      final result = await repository.register(
        name: 'Ahmed Hassan',
        email: 'ahmed@example.com',
        phone: '+201013114901',
        password: _password,
        passwordConfirmation: _password,
      );

      final failure = _failureOf(result);
      expect(failure.statusCode, 422);
      expect(failure.message, 'The email has already been taken.');
      expect(failure.fieldErrors['email'], [
        'The email has already been taken.',
      ]);
    });
  });

  group('verifyOtp', () {
    test('saves the token, then resets the session events', () async {
      remote.token = 'jwt-token';

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '123456',
      );

      expect(result, _success);
      expect(storage.savedTokens, ['jwt-token']);
      expect(log, ['remote.verifyOtp', 'storage.saveToken', 'events.reset']);
    });

    test('saves nothing when the code is wrong', () async {
      remote.error = const UnauthorizedException('Invalid or expired OTP');

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '000000',
      );

      expect(_failureOf(result).message, 'Invalid or expired OTP');
      expect(storage.savedTokens, isEmpty);
      expect(sessionEvents.resetCalls, 0);
    });

    test('returns a failure when the token cannot be saved', () async {
      storage.saveError = Exception('disk error');

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '123456',
      );

      expect(_failureOf(result).message, ErrorMessages.unknown);
      expect(sessionEvents.resetCalls, 0);
    });
  });

  group('resendOtp', () {
    test('asks the server to resend the code', () async {
      final result = await repository.resendOtp(email: _email);

      expect(result, _success);
      expect(remote.resendArgs, [_email]);
    });

    test('returns a failure when the server refuses', () async {
      remote.error = const NoInternetException();

      final result = await repository.resendOtp(email: _email);

      expect(_failureOf(result).message, ErrorMessages.noInternet);
    });
  });

  group('logout', () {
    test('calls the server, then clears the token', () async {
      final result = await repository.logout();

      expect(result, _success);
      expect(log, ['remote.logout', 'storage.clearToken']);
    });

    for (final exception in <AppException>[
      const NoInternetException(),
      const UnauthorizedException(),
    ]) {
      test(
        'still clears the token and succeeds after a ${exception.runtimeType}',
        () async {
          remote.error = exception;

          final result = await repository.logout();

          expect(result, _success);
          expect(storage.clearCalls, 1);
        },
      );
    }

    test('clears the token even when something unexpected fails', () async {
      remote.error = StateError('boom');

      final result = await repository.logout();

      expect(_failureOf(result).message, ErrorMessages.unknown);
      expect(storage.clearCalls, 1);
    });
  });

  group('hasValidSession', () {
    test('is false when there is no token', () async {
      storage.token = null;

      expect(await repository.hasValidSession(), isFalse);
      expect(storage.clearCalls, 0);
    });

    test('is false when the token is empty', () async {
      storage.token = '';

      expect(await repository.hasValidSession(), isFalse);
      expect(storage.clearCalls, 0);
    });

    test('is true for a token that has not expired', () async {
      storage.token = buildJwt(expiresIn: const Duration(hours: 1));

      expect(await repository.hasValidSession(), isTrue);
      expect(storage.clearCalls, 0);
    });

    test('is false and clears the token when it has expired', () async {
      storage.token = buildJwt(expiresIn: const Duration(hours: -1));

      expect(await repository.hasValidSession(), isFalse);
      expect(storage.clearCalls, 1);
    });

    test('is false and clears the token when it is malformed', () async {
      storage.token = 'garbage';

      expect(await repository.hasValidSession(), isFalse);
      expect(storage.clearCalls, 1);
    });
  });
}
