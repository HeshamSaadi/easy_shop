import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> register(RegisterParams params);
}
