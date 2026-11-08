import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

class LoginClient {
  const LoginClient(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
