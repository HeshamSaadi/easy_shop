import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

/// Hand-written fake for the Client auth repository.
class FakeClientAuthRepository implements AuthRepository {
  bool sessionResult = false;
  Either<Failure, Unit> result = const Right(unit);

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
  }) async => result;

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async => result;

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async => result;

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async =>
      result;

  @override
  Future<Either<Failure, Unit>> logout() async => result;

  @override
  Future<bool> hasValidSession() async => sessionResult;
}
