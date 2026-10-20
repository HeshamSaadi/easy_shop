import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterParams params);

  Future<void> login({required String email, required String password});

  Future<String> verifyOtp({required String email, required String otpCode});

  Future<void> resendOtp({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  static const String _tokenKey = 'token';

  final ApiConsumer _api;

  @override
  Future<void> register(RegisterParams params) async {
    final form = await _buildRegisterForm(params);
    await _api.post(EndPoints.adminRegister, data: form);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _api.post(
      EndPoints.adminLogin,
      data: {'email': email, 'password': password},
    );
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _api.post(
      EndPoints.adminVerifyOtp,
      data: {'email': email, 'otp_code': otpCode},
    );
    final token = response is Map<String, dynamic> ? response[_tokenKey] : null;
    if (token is! String || token.isEmpty) {
      throw const ServerException();
    }
    return token;
  }

  @override
  Future<void> resendOtp({required String email}) async {
    await _api.post(EndPoints.adminResendOtp, data: {'email': email});
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
      'address': ?params.address,
      'latitude': ?params.latitude,
      'longitude': ?params.longitude,
      'picture': ?picture,
      'commercial_register': ?commercialRegister,
      'tax_card': ?taxCard,
    });
  }

  Future<MultipartFile?> _fileOrNull(String? path) async {
    if (path == null) return null;
    return MultipartFile.fromFile(path);
  }
}
