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
}
