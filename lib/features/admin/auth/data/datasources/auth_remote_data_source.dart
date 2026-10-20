import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<void> register(RegisterParams params) async {
    final form = await _buildRegisterForm(params);
    await _api.post(EndPoints.adminRegister, data: form);
  }

  Future<FormData> _buildRegisterForm(RegisterParams params) async {
    final picture = await _fileOrNull(params.picturePath);
    final commercialRegister = await _fileOrNull(params.commercialRegisterPath);
    final taxCard = await _fileOrNull(params.taxCardPath);

    return FormData.fromMap({
      'name': params.name,
      'email': params.email,
      'phone': params.phone,
      'national_id': params.nationalId,
      'business_name': params.businessName,
      'password': params.password,
      'password_confirmation': params.passwordConfirmation,
      if (params.address != null) 'address': params.address,
      if (params.latitude != null) 'latitude': params.latitude,
      if (params.longitude != null) 'longitude': params.longitude,
      if (picture != null) 'picture': picture,
      if (commercialRegister != null) 'commercial_register': commercialRegister,
      if (taxCard != null) 'tax_card': taxCard,
    });
  }

  Future<MultipartFile?> _fileOrNull(String? path) async {
    if (path == null) return null;
    return MultipartFile.fromFile(path);
  }
}
