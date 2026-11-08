import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

class LogoutClient {
  const LogoutClient(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
