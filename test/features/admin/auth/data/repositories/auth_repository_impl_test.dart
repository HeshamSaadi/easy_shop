import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/core/errors/error_messages.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/data/repositories/auth_repository_impl.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/jwt_helper.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockSessionEvents extends Mock implements SessionEvents {}

const _email = 'admin@shop.com';
const _password = '12345678';
const _success = Right<Failure, Unit>(unit);

const _registerParams = RegisterParams(
  name: 'Ahmed Hassan',
  email: 'ahmed@example.com',
  phone: '+201013114901',
  nationalId: '29001011234567',
  businessName: 'Elbatal Store',
  password: _password,
  passwordConfirmation: _password,
);

Failure _failureOf(Either<Failure, Unit> result) {
  return result.fold((failure) => failure, (_) => fail('Expected a failure'));
}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockTokenStorage storage;
  late MockSessionEvents sessionEvents;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_registerParams);
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    storage = MockTokenStorage();
    sessionEvents = MockSessionEvents();
    repository = AuthRepositoryImpl(remote, storage, sessionEvents);
  });

  When<Future<void>> whenLogin() => when(
    () => remote.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  );

  When<Future<String>> whenVerifyOtp() => when(
    () => remote.verifyOtp(
      email: any(named: 'email'),
      otpCode: any(named: 'otpCode'),
    ),
  );

  group('login', () {
    test('forwards the credentials and returns unit', () async {
      whenLogin().thenAnswer((_) async {});

      final result = await repository.login(email: _email, password: _password);

      expect(result, _success);
      verify(() => remote.login(email: _email, password: _password)).called(1);
    });

    test('returns the server message and status code on a 401', () async {
      whenLogin().thenThrow(const UnauthorizedException('Invalid email or password'));

      final result = await repository.login(email: _email, password: 'wrong');

      final failure = _failureOf(result);
      expect(failure.message, 'Invalid email or password');
      expect(failure.statusCode, 401);
    });

    test('returns the friendly message when there is no internet', () async {
      whenLogin().thenThrow(const NoInternetException());

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.noInternet);
    });

    test('returns the friendly message on a timeout', () async {
      whenLogin().thenThrow(const ConnectionTimeoutException());

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.timeout);
    });

    test('returns the friendly message on a server error', () async {
      whenLogin().thenThrow(const ServerException(statusCode: 500));

      final result = await repository.login(email: _email, password: _password);

      final failure = _failureOf(result);
      expect(failure.message, ErrorMessages.server);
      expect(failure.statusCode, 500);
    });

    test('turns an unexpected error into the unknown message', () async {
      whenLogin().thenThrow(StateError('boom'));

      final result = await repository.login(email: _email, password: _password);

      expect(_failureOf(result).message, ErrorMessages.unknown);
    });
  });

  group('register', () {
    test('returns unit when the server accepts the account', () async {
      when(() => remote.register(any())).thenAnswer((_) async {});

      final result = await repository.register(_registerParams);

      expect(result, _success);
      verify(() => remote.register(_registerParams)).called(1);
    });

    test('keeps the errors of each field on a 422', () async {
      when(() => remote.register(any())).thenThrow(
        const BadRequestException(
          'The email has already been taken.',
          statusCode: 422,
          fieldErrors: {
            'email': ['The email has already been taken.'],
          },
        ),
      );

      final result = await repository.register(_registerParams);

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
      whenVerifyOtp().thenAnswer((_) async => 'jwt-token');
      when(() => storage.saveToken(any())).thenAnswer((_) async {});

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '123456',
      );

      expect(result, _success);
      verifyInOrder([
        () => storage.saveToken('jwt-token'),
        () => sessionEvents.reset(),
      ]);
    });

    test('saves nothing when the code is wrong', () async {
      whenVerifyOtp().thenThrow(const UnauthorizedException('Invalid or expired OTP'));

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '000000',
      );

      expect(_failureOf(result).message, 'Invalid or expired OTP');
      verifyNever(() => storage.saveToken(any()));
      verifyNever(() => sessionEvents.reset());
    });

    test('returns a failure when the token cannot be saved', () async {
      whenVerifyOtp().thenAnswer((_) async => 'jwt-token');
      when(() => storage.saveToken(any())).thenThrow(Exception('disk error'));

      final result = await repository.verifyOtp(
        email: _email,
        otpCode: '123456',
      );

      expect(_failureOf(result).message, ErrorMessages.unknown);
      verifyNever(() => sessionEvents.reset());
    });
  });

  group('resendOtp', () {
    test('asks the server to resend the code', () async {
      when(
        () => remote.resendOtp(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      final result = await repository.resendOtp(email: _email);

      expect(result, _success);
      verify(() => remote.resendOtp(email: _email)).called(1);
    });

    test('returns a failure when the server refuses', () async {
      when(
        () => remote.resendOtp(email: any(named: 'email')),
      ).thenThrow(const NoInternetException());

      final result = await repository.resendOtp(email: _email);

      expect(_failureOf(result).message, ErrorMessages.noInternet);
    });
  });

  group('logout', () {
    setUp(() {
      when(() => storage.clearToken()).thenAnswer((_) async {});
    });

    test('calls the server, then clears the token', () async {
      when(() => remote.logout()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, _success);
      verifyInOrder([() => remote.logout(), () => storage.clearToken()]);
    });

    for (final exception in <AppException>[
      const NoInternetException(),
      const UnauthorizedException(),
    ]) {
      test('still clears the token and succeeds after a ${exception.runtimeType}', () async {
        when(() => remote.logout()).thenThrow(exception);

        final result = await repository.logout();

        expect(result, _success);
        verify(() => storage.clearToken()).called(1);
      });
    }

    test('clears the token even when something unexpected fails', () async {
      when(() => remote.logout()).thenThrow(StateError('boom'));

      final result = await repository.logout();

      expect(_failureOf(result).message, ErrorMessages.unknown);
      verify(() => storage.clearToken()).called(1);
    });
  });

  group('hasValidSession', () {
    void stubToken(String? token) {
      when(() => storage.readToken()).thenAnswer((_) async => token);
      when(() => storage.clearToken()).thenAnswer((_) async {});
    }

    test('is false when there is no token', () async {
      stubToken(null);

      expect(await repository.hasValidSession(), isFalse);
      verifyNever(() => storage.clearToken());
    });

    test('is false when the token is empty', () async {
      stubToken('');

      expect(await repository.hasValidSession(), isFalse);
      verifyNever(() => storage.clearToken());
    });

    test('is true for a token that has not expired', () async {
      stubToken(buildJwt(expiresIn: const Duration(hours: 1)));

      expect(await repository.hasValidSession(), isTrue);
      verifyNever(() => storage.clearToken());
    });

    test('is false and clears the token when it has expired', () async {
      stubToken(buildJwt(expiresIn: const Duration(hours: -1)));

      expect(await repository.hasValidSession(), isFalse);
      verify(() => storage.clearToken()).called(1);
    });

    test('is false and clears the token when it is malformed', () async {
      stubToken('garbage');

      expect(await repository.hasValidSession(), isFalse);
      verify(() => storage.clearToken()).called(1);
    });
  });
}
