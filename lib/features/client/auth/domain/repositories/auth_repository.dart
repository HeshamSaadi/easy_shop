import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';

abstract class AuthRepository {
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
  });

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
