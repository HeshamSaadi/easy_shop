import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

/// Hand-written fake: the tests set the results and read the call counters.
class FakeAuthRepository implements AuthRepository {
  Either<Failure, Unit> loginResult = const Right(unit);
  Either<Failure, Unit> verifyResult = const Right(unit);
  Either<Failure, Unit> resendResult = const Right(unit);
  Either<Failure, Unit> registerResult = const Right(unit);
  Either<Failure, Unit> logoutResult = const Right(unit);
  bool sessionResult = false;

  /// When set, login waits for it, so a test can keep a call "in flight".
  Completer<void>? loginGate;

  /// Same idea as [loginGate], for verify and resend.
  Completer<void>? verifyGate;
  Completer<void>? resendGate;
  Completer<void>? registerGate;

  int loginCalls = 0;
  int verifyCalls = 0;
  int resendCalls = 0;
  int logoutCalls = 0;

  /// What the use cases sent, in order.
  final List<RegisterParams> registerArgs = [];
  final List<({String email, String password})> loginArgs = [];
  final List<({String email, String otpCode})> verifyArgs = [];
  final List<String> resendArgs = [];

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    loginArgs.add((email: email, password: password));
    await loginGate?.future;
    return loginResult;
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    verifyCalls++;
    verifyArgs.add((email: email, otpCode: otpCode));
    await verifyGate?.future;
    return verifyResult;
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    resendCalls++;
    resendArgs.add(email);
    await resendGate?.future;
    return resendResult;
  }

  @override
  Future<Either<Failure, Unit>> register(RegisterParams params) async {
    registerArgs.add(params);
    await registerGate?.future;
    return registerResult;
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return logoutResult;
  }

  @override
  Future<bool> hasValidSession() async => sessionResult;
}
