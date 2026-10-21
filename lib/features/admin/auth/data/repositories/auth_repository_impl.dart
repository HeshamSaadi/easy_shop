import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remote,
    this._tokenStorage,
    this._sessionEvents,
  );

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;

  @override
  Future<Either<Failure, Unit>> register(RegisterParams params) {
    return guardedUnitCall(() => _remote.register(params));
  }

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) {
    return guardedUnitCall(
      () => _remote.login(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) {
    return guardedUnitCall(() async {
      final token = await _remote.verifyOtp(email: email, otpCode: otpCode);
      await _tokenStorage.saveToken(token);
      _sessionEvents.reset();
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() {
    return guardedUnitCall(() async {
      try {
        await _remote.logout();
      } on AppException {
        // The server call can fail (expired token, no internet).
        // The user must still be logged out on this device.
      } finally {
        await _tokenStorage.clearToken();
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) {
    return guardedUnitCall(() => _remote.resendOtp(email: email));
  }
}
