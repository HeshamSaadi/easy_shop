import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/multipart_helper.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/profile/data/models/profile_model.dart';
import 'package:easy_shop/features/admin/profile/domain/params/update_profile_params.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<void> updateProfile(UpdateProfileParams params);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._api);

  static const String _dataKey = 'data';

  final ApiConsumer _api;

  @override
  Future<ProfileModel> getProfile() async {
    final response = await _api.get(EndPoints.adminProfile);
    final data = response is Map<String, dynamic> ? response[_dataKey] : null;
    if (data is! Map<String, dynamic>) {
      throw const ServerException();
    }
    return ProfileModel.fromJson(data);
  }

  @override
  Future<void> updateProfile(UpdateProfileParams params) async {
    final form = await _buildUpdateForm(params);
    await _api.put(EndPoints.adminProfileUpdate, data: form);
  }

  Future<FormData> _buildUpdateForm(UpdateProfileParams params) async {
    final picture = await multipartFileOrNull(params.picturePath);
    final commercialRegister = await multipartFileOrNull(
      params.commercialRegisterPath,
    );
    final taxCard = await multipartFileOrNull(params.taxCardPath);

    return FormData.fromMap({
      'name': params.name,
      'email': params.email,
      'phone': params.phone,
      'national_id': params.nationalId,
      'business_name': params.businessName,
      'address': ?params.address,
      'latitude': ?params.latitude,
      'longitude': ?params.longitude,
      'picture': ?picture,
      'commercial_register': ?commercialRegister,
      'tax_card': ?taxCard,
    });
  }
}
