import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

/// Hand-written fake for tests. Every call succeeds, and the saved session is
/// set by the constructor.
class FakeClientAuthRepository implements AuthRepository {
  FakeClientAuthRepository({this.hasSession = false});

  final bool hasSession;

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
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> verifyOtp({
    required String email,
    required String otpCode,
  }) async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> resendOtp({required String email}) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<bool> hasValidSession() async => hasSession;
}
