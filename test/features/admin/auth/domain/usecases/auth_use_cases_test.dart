import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/register_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

const _success = Right<Failure, Unit>(unit);
const _failure = Failure('Invalid or expired OTP', statusCode: 401);
const _failed = Left<Failure, Unit>(_failure);

const _email = 'admin@shop.com';

RegisterParams _registerParams({String phone = '+201013114901'}) {
  return RegisterParams(
    name: 'Ahmed Hassan',
    email: 'ahmed@example.com',
    phone: phone,
    nationalId: '29001011234567',
    businessName: 'Elbatal Store',
    password: '12345678',
    passwordConfirmation: '12345678',
    address: '123 Tahrir Square',
    latitude: 30.0444,
    longitude: 31.2357,
  );
}

void main() {
  late MockAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(_registerParams());
  });

  setUp(() {
    repository = MockAuthRepository();
  });

  group('LoginAdmin', () {
    test('sends the email and password to the repository', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _success);

      final result = await LoginAdmin(
        repository,
      )(email: _email, password: '12345678');

      expect(result, _success);
      verify(
        () => repository.login(email: _email, password: '12345678'),
      ).called(1);
    });

    test('returns the failure unchanged', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _failed);

      final result = await LoginAdmin(
        repository,
      )(email: _email, password: 'wrong-password');

      expect(result, _failed);
    });
  });

  group('VerifyOtp', () {
    test('sends the email and the code to the repository', () async {
      when(
        () => repository.verifyOtp(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
        ),
      ).thenAnswer((_) async => _success);

      final result = await VerifyOtp(
        repository,
      )(email: _email, otpCode: '123456');

      expect(result, _success);
      verify(
        () => repository.verifyOtp(email: _email, otpCode: '123456'),
      ).called(1);
    });

    test('returns the failure unchanged', () async {
      when(
        () => repository.verifyOtp(
          email: any(named: 'email'),
          otpCode: any(named: 'otpCode'),
        ),
      ).thenAnswer((_) async => _failed);

      final result = await VerifyOtp(
        repository,
      )(email: _email, otpCode: '000000');

      expect(result, _failed);
    });
  });

  group('ResendOtp', () {
    test('asks the repository to resend the code to the email', () async {
      when(
        () => repository.resendOtp(email: any(named: 'email')),
      ).thenAnswer((_) async => _success);

      final result = await ResendOtp(repository)(email: _email);

      expect(result, _success);
      verify(() => repository.resendOtp(email: _email)).called(1);
    });

    test('returns the failure unchanged', () async {
      when(
        () => repository.resendOtp(email: any(named: 'email')),
      ).thenAnswer((_) async => _failed);

      final result = await ResendOtp(repository)(email: _email);

      expect(result, _failed);
    });
  });

  group('LogoutAdmin', () {
    test('asks the repository to log out', () async {
      when(() => repository.logout()).thenAnswer((_) async => _success);

      final result = await LogoutAdmin(repository)();

      expect(result, _success);
      verify(() => repository.logout()).called(1);
    });
  });

  group('RestoreSession', () {
    test('returns true when the repository has a valid session', () async {
      when(() => repository.hasValidSession()).thenAnswer((_) async => true);

      expect(await RestoreSession(repository)(), isTrue);
    });

    test('returns false when there is no valid session', () async {
      when(() => repository.hasValidSession()).thenAnswer((_) async => false);

      expect(await RestoreSession(repository)(), isFalse);
    });
  });

  group('RegisterAdmin', () {
    Future<RegisterParams> registerAndCapture(RegisterParams params) async {
      when(() => repository.register(any())).thenAnswer((_) async => _success);

      await RegisterAdmin(repository)(params);

      final captured = verify(
        () => repository.register(captureAny()),
      ).captured;
      return captured.single as RegisterParams;
    }

    test('removes every kind of whitespace from the phone', () async {
      final sent = await registerAndCapture(
        _registerParams(phone: '+20 101\t311 4901'),
      );

      expect(sent.phone, '+201013114901');
    });

    test('keeps a phone that has no whitespace as it is', () async {
      final sent = await registerAndCapture(_registerParams());

      expect(sent.phone, '+201013114901');
    });

    test('passes all the other fields through unchanged', () async {
      final params = _registerParams();

      final sent = await registerAndCapture(params);

      expect(sent.name, params.name);
      expect(sent.email, params.email);
      expect(sent.nationalId, params.nationalId);
      expect(sent.businessName, params.businessName);
      expect(sent.password, params.password);
      expect(sent.passwordConfirmation, params.passwordConfirmation);
      expect(sent.address, params.address);
      expect(sent.latitude, params.latitude);
      expect(sent.longitude, params.longitude);
    });

    test('keeps the optional fields empty when they were not given', () async {
      const params = RegisterParams(
        name: 'Ahmed Hassan',
        email: 'ahmed@example.com',
        phone: '+201013114901',
        nationalId: '29001011234567',
        businessName: 'Elbatal Store',
        password: '12345678',
        passwordConfirmation: '12345678',
      );

      final sent = await registerAndCapture(params);

      expect(sent.address, isNull);
      expect(sent.latitude, isNull);
      expect(sent.longitude, isNull);
      expect(sent.picturePath, isNull);
      expect(sent.commercialRegisterPath, isNull);
      expect(sent.taxCardPath, isNull);
    });

    test('returns the failure unchanged', () async {
      when(() => repository.register(any())).thenAnswer((_) async => _failed);

      final result = await RegisterAdmin(repository)(_registerParams());

      expect(result, _failed);
    });
  });
}
