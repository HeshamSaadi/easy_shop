import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';

class RegisterClient {
  const RegisterClient(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, Unit>> call(RegisterParams params) {
    return _repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      picturePath: params.picturePath,
    );
  }
}
