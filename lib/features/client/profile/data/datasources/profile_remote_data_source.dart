import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/multipart_helper.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/client/profile/data/models/client_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ClientModel> getProfile();
  Future<ClientModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? latitude,
    String? longitude,
    String? picturePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiConsumer);

  static const String _methodKey = '_method';
  static const String _putMethod = 'PUT'; // Laravel method spoofing

  final ApiConsumer _apiConsumer;

  @override
  Future<ClientModel> getProfile() async {
    final response = await _apiConsumer.get(EndPoints.clientProfile);
    return ClientModel.fromJson(ResponseReader.object(response));
  }

  @override
  Future<ClientModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    String? latitude,
    String? longitude,
    String? picturePath,
  }) async {
    final picture = await multipartFileOrNull(picturePath);

    final formData = FormData.fromMap({
      _methodKey: _putMethod,
      'name': name,
      'email': email,
      'phone': phone,
      'address': ?address,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'picture': ?picture,
    });

    final response = await _apiConsumer.post(
      EndPoints.clientProfileUpdate,
      data: formData,
    );

    return ClientModel.fromJson(ResponseReader.object(response));
  }
}