import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/multipart_helper.dart';
import 'package:easy_shop/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  });

  Future<void> login({required String email, required String password});

  Future<String> verifyOtp({required String email, required String otpCode});

  Future<void> resendOtp({required String email});

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  static const String _tokenKey = 'token';
  final ApiConsumer _api;

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    final picture = await multipartFileOrNull(picturePath);

    final form = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'address': ?address,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'picture': ?picture,
    });

    await _api.post(EndPoints.clientRegister, data: form);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await _api.post(
      EndPoints.clientLogin,
      data: {'email': email, 'password': password},
    );
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _api.post(
      EndPoints.clientVerifyOtp,
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
    await _api.post(EndPoints.clientResendOtp, data: {'email': email});
  }

  @override
  Future<void> logout() async {
    await _api.post(EndPoints.clientLogout);
  }
}
