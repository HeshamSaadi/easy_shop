import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> register(RegisterParams params);
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, Unit>> resendOtp({required String email});

  Future<Either<Failure, Unit>> logout();

  Future<bool> hasValidSession();
}
