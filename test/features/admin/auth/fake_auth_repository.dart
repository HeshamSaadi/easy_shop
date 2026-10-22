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

  /// When set, login waits for it, so a test can keep a call "in flight".
  Completer<void>? loginGate;

  int loginCalls = 0;
  int verifyCalls = 0;
  int resendCalls = 0;

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    await loginGate?.future;
    return loginResult;
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    verifyCalls++;
    return verifyResult;
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    resendCalls++;
    return resendResult;
  }

  @override
  Future<Either<Failure, Unit>> register(RegisterParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    throw UnimplementedError();
  }
}
