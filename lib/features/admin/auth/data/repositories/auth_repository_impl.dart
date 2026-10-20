import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> register(RegisterParams params) async {
    try {
      await _remote.register(params);
      return const Right(unit);
    } on AppException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      return Left(Failure.fromException(const UnknownException()));
    }
  }
}
