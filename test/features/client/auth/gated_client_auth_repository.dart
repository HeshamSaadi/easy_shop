import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';

import 'fake_client_auth_repository.dart';

/// The shared fake, plus gates. A call is recorded first, then waits for its
/// gate, so a test can check what happens while a request is still running.
class GatedClientAuthRepository extends FakeClientAuthRepository {
  Completer<void>? registerGate;
  Completer<void>? loginGate;
  Completer<void>? verifyGate;
  Completer<void>? resendGate;

  @override
  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    final result = await super.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
    );
    await registerGate?.future;
    return result;
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    final result = await super.login(email: email, password: password);
    await loginGate?.future;
    return result;
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final result = await super.verifyOtp(email: email, otpCode: otpCode);
    await verifyGate?.future;
    return result;
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async {
    final result = await super.resendOtp(email: email);
    await resendGate?.future;
    return result;
  }
}
