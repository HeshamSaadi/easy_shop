import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.hasValidSession();
  }
}
