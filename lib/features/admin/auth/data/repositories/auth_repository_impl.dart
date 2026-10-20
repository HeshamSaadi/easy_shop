import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, Unit>> register(RegisterParams params) {
    return _guard(() => _remote.register(params));
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) {
    return _guard(() => _remote.login(email: email, password: password));
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) {
    return _guard(() async {
      final token = await _remote.verifyOtp(email: email, otpCode: otpCode);
      await _tokenStorage.saveToken(token);
    });
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) {
    return _guard(() => _remote.resendOtp(email: email));
  }

  Future<Either<Failure, Unit>> _guard(Future<void> Function() action) async {
    try {
      await action();
      return const Right(unit);
    } on AppException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      return Left(Failure.fromException(const UnknownException()));
    }
  }
}
