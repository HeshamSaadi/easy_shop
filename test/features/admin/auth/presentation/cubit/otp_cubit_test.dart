import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_auth_repository.dart';

Matcher _hasStatus(OtpStatus status) {
  return isA<OtpState>().having((s) => s.status, 'status', status);
}

void main() {
  late FakeAuthRepository repository;
  late OtpCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = OtpCubit(
      email: 'a@b.com',
      verifyOtp: VerifyOtp(repository),
      resendOtp: ResendOtp(repository),
    );
  });

  test('starts idle with the full 10 minutes', () {
    expect(cubit.state.status, OtpStatus.idle);
    expect(cubit.state.remaining, OtpCubit.validity);
    addTearDown(cubit.close);
  });

  test('verify emits verifying then verified', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        _hasStatus(OtpStatus.verifying),
        _hasStatus(OtpStatus.verified),
      ]),
    );

    await cubit.verify('123456');
    await expectation;
    await cubit.close();
  });

  test('verify failure keeps the server message', () async {
    repository.verifyResult = const Left(Failure('Invalid or expired OTP'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        _hasStatus(OtpStatus.verifying),
        isA<OtpState>()
            .having((s) => s.status, 'status', OtpStatus.verifyFailed)
            .having((s) => s.message, 'message', 'Invalid or expired OTP'),
      ]),
    );

    await cubit.verify('000000');
    await expectation;
    await cubit.close();
  });

  testWidgets('the countdown goes down one second at a time', (tester) async {
    cubit.start();
    await tester.pump(const Duration(seconds: 3));

    expect(
      cubit.state.remaining,
      OtpCubit.validity - const Duration(seconds: 3),
    );
    await cubit.close();
  });

  testWidgets('verify is ignored after the code expired', (tester) async {
    cubit.start();
    await tester.pump(OtpCubit.validity);
    expect(cubit.state.isExpired, isTrue);

    await cubit.verify('123456');

    expect(repository.verifyCalls, 0);
    expect(cubit.state.status, OtpStatus.idle);
    await cubit.close();
  });

  testWidgets('resend restarts the countdown', (tester) async {
    cubit.start();
    await tester.pump(const Duration(minutes: 5));
    expect(cubit.state.remaining, const Duration(minutes: 5));

    await cubit.resend();

    expect(repository.resendCalls, 1);
    expect(cubit.state.status, OtpStatus.resent);
    expect(cubit.state.remaining, OtpCubit.validity);
    await cubit.close();
  });

  testWidgets('resend failure keeps the message and the countdown', (
    tester,
  ) async {
    repository.resendResult = const Left(Failure('No internet connection.'));
    cubit.start();
    await tester.pump(const Duration(minutes: 1));

    await cubit.resend();

    expect(cubit.state.status, OtpStatus.resendFailed);
    expect(cubit.state.message, 'No internet connection.');
    expect(cubit.state.remaining, const Duration(minutes: 9));
    await cubit.close();
  });

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

  test('verify sends the email and the code', () async {
    await cubit.verify('123456');

    expect(repository.verifyArgs, [(email: 'a@b.com', otpCode: '123456')]);
    await cubit.close();
  });

  test('resend sends the email', () async {
    await cubit.resend();

    expect(repository.resendArgs, ['a@b.com']);
    await cubit.close();
  });

  test('ignores verify and resend while a verify is running', () async {
    final gate = Completer<void>();
    repository.verifyGate = gate;

    final first = cubit.verify('123456');
    await cubit.verify('123456');
    await cubit.resend();
    gate.complete();
    await first;

    expect(repository.verifyCalls, 1);
    expect(repository.resendCalls, 0);
    await cubit.close();
  });

  test('ignores verify and resend while a resend is running', () async {
    final gate = Completer<void>();
    repository.resendGate = gate;

    final first = cubit.resend();
    await cubit.resend();
    await cubit.verify('123456');
    gate.complete();
    await first;

    expect(repository.resendCalls, 1);
    expect(repository.verifyCalls, 0);
    await cubit.close();
  });

  test('clears the old error message when a new resend starts', () async {
    repository.verifyResult = const Left(Failure('Invalid or expired OTP'));
    await cubit.verify('000000');
    expect(cubit.state.message, 'Invalid or expired OTP');

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OtpState>()
            .having((s) => s.status, 'status', OtpStatus.resending)
            .having((s) => s.message, 'message', isNull),
        _hasStatus(OtpStatus.resent),
      ]),
    );

    await cubit.resend();
    await expectation;
    await cubit.close();
  });

  testWidgets('the countdown stops at zero and the code is expired', (
    tester,
  ) async {
    cubit.start();

    await tester.pump(OtpCubit.validity);
    expect(cubit.state.remaining, Duration.zero);
    expect(cubit.state.isExpired, isTrue);

    await tester.pump(const Duration(seconds: 5));
    expect(cubit.state.remaining, Duration.zero);
    await cubit.close();
  });

  testWidgets('the countdown stops after a successful verification', (
    tester,
  ) async {
    cubit.start();
    await tester.pump(const Duration(seconds: 2));

    await cubit.verify('123456');
    final remainingWhenVerified = cubit.state.remaining;
    await tester.pump(const Duration(seconds: 5));

    expect(cubit.state.status, OtpStatus.verified);
    expect(cubit.state.remaining, remainingWhenVerified);
    await cubit.close();
  });

  testWidgets('resend after the code expired starts again from 10 minutes', (
    tester,
  ) async {
    cubit.start();
    await tester.pump(OtpCubit.validity);
    expect(cubit.state.isExpired, isTrue);

    await cubit.resend();
    expect(cubit.state.status, OtpStatus.resent);
    expect(cubit.state.remaining, OtpCubit.validity);

    await tester.pump(const Duration(seconds: 2));
    expect(
      cubit.state.remaining,
      OtpCubit.validity - const Duration(seconds: 2),
    );
    await cubit.close();
  });
}
