import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String otpCode,
  }) {
    return _repository.verifyOtp(email: email, otpCode: otpCode);
  }
}
