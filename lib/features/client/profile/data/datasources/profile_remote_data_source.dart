import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/multipart_helper.dart';
import 'package:easy_shop/features/client/profile/data/models/client_model.dart';

/// Remote data source for client profile operations.
///
/// Handles API calls related to client profile management.
abstract class ProfileRemoteDataSource {
  /// Fetches the current authenticated client's profile.
  Future<ClientModel> getProfile();

  /// Updates the current authenticated client's profile.
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

  final ApiConsumer _apiConsumer;

  @override
  Future<ClientModel> getProfile() async {
    final response = await _apiConsumer.get(EndPoints.clientProfile);
    return ClientModel.fromJson(response['data'] as Map<String, dynamic>);
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
      '_method': 'PUT', // Laravel method spoofing
      'name': name,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (picture != null) 'picture': picture,
    });

    final response = await _apiConsumer.post(
      EndPoints.clientProfileUpdate,
      data: formData,
    );

    return ClientModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
