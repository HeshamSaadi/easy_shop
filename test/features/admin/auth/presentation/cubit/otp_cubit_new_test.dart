import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockResendOtp extends Mock implements ResendOtp {}

const _email = 'admin@shop.com';
const _code = '123456';

const _success = Right<Failure, Unit>(unit);
const _wrongCode = Failure('Invalid or expired OTP', statusCode: 401);
const _verifyFailed = Left<Failure, Unit>(_wrongCode);
const _noInternet = Failure('No internet connection.');
const _resendFailed = Left<Failure, Unit>(_noInternet);

TypeMatcher<OtpState> _status(OtpStatus status) {
  return isA<OtpState>().having((state) => state.status, 'status', status);
}

void main() {
  late MockVerifyOtp verifyOtp;
  late MockResendOtp resendOtp;

  setUp(() {
    verifyOtp = MockVerifyOtp();
    resendOtp = MockResendOtp();
  });

  void stubVerify(Either<Failure, Unit> result) {
    when(
      () => verifyOtp(
        email: any(named: 'email'),
        otpCode: any(named: 'otpCode'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubResend(Either<Failure, Unit> result) {
    when(
      () => resendOtp(email: any(named: 'email')),
    ).thenAnswer((_) async => result);
  }

  OtpCubit buildCubit() {
    return OtpCubit(email: _email, verifyOtp: verifyOtp, resendOtp: resendOtp);
  }

  group('OtpState', () {
    test('is expired only when no time is left', () {
      expect(const OtpState(remaining: Duration.zero).isExpired, isTrue);
      expect(
        const OtpState(remaining: Duration(seconds: 1)).isExpired,
        isFalse,
      );
    });

    test('is busy only while verifying or resending', () {
      const busy = [OtpStatus.verifying, OtpStatus.resending];

      for (final status in OtpStatus.values) {
        final state = OtpState(remaining: OtpCubit.validity, status: status);
        expect(state.isBusy, busy.contains(status), reason: '$status');
      }
    });

    test('copyWith clears the message unless a new one is given', () {
      const failed = OtpState(
        remaining: OtpCubit.validity,
        status: OtpStatus.verifyFailed,
        message: 'Invalid or expired OTP',
      );

      expect(failed.copyWith(status: OtpStatus.resending).message, isNull);
      expect(failed.copyWith(message: 'Again').message, 'Again');
    });

    test('copyWith keeps the fields that are not changed', () {
      const state = OtpState(
        remaining: Duration(minutes: 4),
        status: OtpStatus.resent,
      );

      final next = state.copyWith(remaining: const Duration(minutes: 3));

      expect(next.remaining, const Duration(minutes: 3));
      expect(next.status, OtpStatus.resent);
    });
  });

  group('initial state', () {
    test('has the full 10 minutes and is idle', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.remaining, OtpCubit.validity);
      expect(cubit.state.remaining, const Duration(minutes: 10));
      expect(cubit.state.status, OtpStatus.idle);
    });
  });

  group('verify', () {
    blocTest<OtpCubit, OtpState>(
      'emits verifying then verified when the code is right',
      setUp: () => stubVerify(_success),
      build: buildCubit,
      act: (cubit) => cubit.verify(_code),
      expect: () => [_status(OtpStatus.verifying), _status(OtpStatus.verified)],
      verify: (_) {
        verify(() => verifyOtp(email: _email, otpCode: _code)).called(1);
      },
    );

    blocTest<OtpCubit, OtpState>(
      'emits verifying then verifyFailed with the message when the code is wrong',
      setUp: () => stubVerify(_verifyFailed),
      build: buildCubit,
      act: (cubit) => cubit.verify('000000'),
      expect: () => [
        _status(OtpStatus.verifying),
        _status(OtpStatus.verifyFailed).having(
          (state) => state.message,
          'message',
          'Invalid or expired OTP',
        ),
      ],
    );

    blocTest<OtpCubit, OtpState>(
      'does not send a code that has expired',
      build: buildCubit,
      seed: () => const OtpState(remaining: Duration.zero),
      act: (cubit) => cubit.verify(_code),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(
          () => verifyOtp(
            email: any(named: 'email'),
            otpCode: any(named: 'otpCode'),
          ),
        );
      },
    );

    for (final busy in [OtpStatus.verifying, OtpStatus.resending]) {
      blocTest<OtpCubit, OtpState>(
        'ignores a second tap while the status is $busy',
        build: buildCubit,
        seed: () => OtpState(remaining: OtpCubit.validity, status: busy),
        act: (cubit) => cubit.verify(_code),
        expect: () => <Matcher>[],
        verify: (_) {
          verifyNever(
            () => verifyOtp(
              email: any(named: 'email'),
              otpCode: any(named: 'otpCode'),
            ),
          );
        },
      );
    }
  });

  group('resend', () {
    blocTest<OtpCubit, OtpState>(
      'emits resending then resent and gives back the full 10 minutes',
      setUp: () => stubResend(_success),
      build: buildCubit,
      seed: () => const OtpState(remaining: Duration(minutes: 4)),
      act: (cubit) => cubit.resend(),
      expect: () => [
        _status(OtpStatus.resending),
        _status(OtpStatus.resent).having(
          (state) => state.remaining,
          'remaining',
          OtpCubit.validity,
        ),
      ],
      verify: (_) {
        verify(() => resendOtp(email: _email)).called(1);
      },
    );

    blocTest<OtpCubit, OtpState>(
      'emits resending then resendFailed with the message when it fails',
      setUp: () => stubResend(_resendFailed),
      build: buildCubit,
      act: (cubit) => cubit.resend(),
      expect: () => [
        _status(OtpStatus.resending),
        _status(OtpStatus.resendFailed).having(
          (state) => state.message,
          'message',
          'No internet connection.',
        ),
      ],
    );

    blocTest<OtpCubit, OtpState>(
      'clears the old error message when a new resend starts',
      setUp: () => stubResend(_success),
      build: buildCubit,
      seed: () => const OtpState(
        remaining: OtpCubit.validity,
        status: OtpStatus.verifyFailed,
        message: 'Invalid or expired OTP',
      ),
      act: (cubit) => cubit.resend(),
      expect: () => [
        _status(OtpStatus.resending).having(
          (state) => state.message,
          'message',
          isNull,
        ),
        _status(OtpStatus.resent),
      ],
    );

    for (final busy in [OtpStatus.verifying, OtpStatus.resending]) {
      blocTest<OtpCubit, OtpState>(
        'ignores a second tap while the status is $busy',
        build: buildCubit,
        seed: () => OtpState(remaining: OtpCubit.validity, status: busy),
        act: (cubit) => cubit.resend(),
        expect: () => <Matcher>[],
        verify: (_) {
          verifyNever(() => resendOtp(email: any(named: 'email')));
        },
      );
    }
  });

  group('countdown', () {
    test('goes down one second at a time', () {
      fakeAsync((async) {
        final cubit = buildCubit()..start();

        async.elapse(const Duration(seconds: 3));

        expect(
          cubit.state.remaining,
          OtpCubit.validity - const Duration(seconds: 3),
        );
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('stops at zero and marks the code as expired', () {
      fakeAsync((async) {
        final cubit = buildCubit()..start();

        async.elapse(OtpCubit.validity);

        expect(cubit.state.remaining, Duration.zero);
        expect(cubit.state.isExpired, isTrue);

        async.elapse(const Duration(seconds: 5));

        expect(cubit.state.remaining, Duration.zero);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('stops after a successful verification', () {
      fakeAsync((async) {
        stubVerify(_success);
        final cubit = buildCubit()..start();
        async.elapse(const Duration(seconds: 2));

        cubit.verify(_code);
        async.flushMicrotasks();
        final remainingWhenVerified = cubit.state.remaining;

        async.elapse(const Duration(seconds: 5));

        expect(cubit.state.status, OtpStatus.verified);
        expect(cubit.state.remaining, remainingWhenVerified);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('starts again from 10 minutes after a resend', () {
      fakeAsync((async) {
        stubResend(_success);
        final cubit = buildCubit()..start();
        async.elapse(OtpCubit.validity);
        expect(cubit.state.isExpired, isTrue);

        cubit.resend();
        async.flushMicrotasks();

        expect(cubit.state.status, OtpStatus.resent);
        expect(cubit.state.remaining, OtpCubit.validity);

        async.elapse(const Duration(seconds: 2));

        expect(
          cubit.state.remaining,
          OtpCubit.validity - const Duration(seconds: 2),
        );
        cubit.close();
        async.flushMicrotasks();
      });
    });
  });
}