import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/login_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/logout_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/register_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_client_auth_repository.dart';

const _success = Right<Failure, Unit>(unit);
const _failure = Failure('Invalid or expired OTP', statusCode: 401);
const _failed = Left<Failure, Unit>(_failure);

const _email = 'client@shop.com';

void main() {
  late FakeClientAuthRepository repository;

  setUp(() {
    repository = FakeClientAuthRepository();
  });

  group('LoginClient', () {
    test('sends the email and password to the repository', () async {
      final result = await LoginClient(repository)(
        email: _email,
        password: '12345678',
      );

      expect(result, _success);
      expect(repository.loginArgs, [(email: _email, password: '12345678')]);
    });

    test('returns the failure unchanged', () async {
      repository.loginResult = _failed;

      final result = await LoginClient(repository)(
        email: _email,
        password: 'wrong-password',
      );

      expect(result, _failed);
    });
  });

  group('VerifyOtp', () {
    test('sends the email and the code to the repository', () async {
      final result = await VerifyOtp(repository)(
        email: _email,
        otpCode: '123456',
      );

      expect(result, _success);
      expect(repository.verifyArgs, [(email: _email, otpCode: '123456')]);
    });

    test('returns the failure unchanged', () async {
      repository.verifyResult = _failed;

      final result = await VerifyOtp(repository)(
        email: _email,
        otpCode: '000000',
      );

      expect(result, _failed);
    });
  });

  group('ResendOtp', () {
    test('asks the repository to resend the code to the email', () async {
      final result = await ResendOtp(repository)(email: _email);

      expect(result, _success);
      expect(repository.resendArgs, [_email]);
    });

    test('returns the failure unchanged', () async {
      repository.resendResult = _failed;

      final result = await ResendOtp(repository)(email: _email);

      expect(result, _failed);
    });
  });

  group('LogoutClient', () {
    test('asks the repository to log out', () async {
      final result = await LogoutClient(repository)();

      expect(result, _success);
      expect(repository.logoutCalls, 1);
    });
  });

  group('RestoreSession', () {
    test('returns true when the repository has a valid session', () async {
      repository.sessionResult = true;

      expect(await RestoreSession(repository)(), isTrue);
    });

    test('returns false when there is no valid session', () async {
      repository.sessionResult = false;

      expect(await RestoreSession(repository)(), isFalse);
    });
  });

  group('RegisterClient', () {
    const base = RegisterParams(
      name: 'Ahmed Hassan',
      email: 'ahmed@example.com',
      phone: '+201013114901',
      password: '12345678',
      passwordConfirmation: '12345678',
    );

    test('removes every kind of whitespace from the phone', () async {
      await RegisterClient(repository)(
        const RegisterParams(
          name: 'Ahmed Hassan',
          email: 'ahmed@example.com',
          phone: '+20 101\t311 4901',
          password: '12345678',
          passwordConfirmation: '12345678',
        ),
      );

      expect(repository.registerArgs.single.phone, '+201013114901');
    });

    test('keeps a phone that has no whitespace as it is', () async {
      await RegisterClient(repository)(base);

      expect(repository.registerArgs.single.phone, '+201013114901');
    });

    test('passes all the other fields through unchanged', () async {
      await RegisterClient(repository)(
        const RegisterParams(
          name: 'Ahmed Hassan',
          email: 'ahmed@example.com',
          phone: '+201013114901',
          password: '12345678',
          passwordConfirmation: '12345678',
          address: '123 Tahrir Square',
          latitude: 30.0444,
          longitude: 31.2357,
        ),
      );

      final sent = repository.registerArgs.single;
      expect(sent.name, 'Ahmed Hassan');
      expect(sent.email, 'ahmed@example.com');
      expect(sent.password, '12345678');
      expect(sent.passwordConfirmation, '12345678');
      expect(sent.address, '123 Tahrir Square');
      expect(sent.latitude, 30.0444);
      expect(sent.longitude, 31.2357);
    });

    test('keeps the optional fields empty when they were not given', () async {
      await RegisterClient(repository)(base);

      final sent = repository.registerArgs.single;
      expect(sent.address, isNull);
      expect(sent.latitude, isNull);
      expect(sent.longitude, isNull);
      expect(sent.picturePath, isNull);
    });

    test('returns the failure unchanged', () async {
      repository.registerResult = _failed;

      final result = await RegisterClient(repository)(base);

      expect(result, _failed);
    });
  });
}
