import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';

class RegisterAdmin {
  const RegisterAdmin(this._repository);

  final AuthRepository _repository;

  static final RegExp _whitespace = RegExp(r'\s+');

  Future<Either<Failure, Unit>> call(RegisterParams params) {
    return _repository.register(
      RegisterParams(
        name: params.name,
        email: params.email,
        phone: params.phone.replaceAll(_whitespace, ''),
        nationalId: params.nationalId,
        businessName: params.businessName,
        password: params.password,
        passwordConfirmation: params.passwordConfirmation,
        address: params.address,
        latitude: params.latitude,
        longitude: params.longitude,
        picturePath: params.picturePath,
        commercialRegisterPath: params.commercialRegisterPath,
        taxCardPath: params.taxCardPath,
      ),
    );
  }
}
