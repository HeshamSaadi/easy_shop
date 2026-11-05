import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/client/profile/data/models/client_model.dart';

/// Remote data source for client profile operations.
///
/// Handles API calls related to client profile management.
abstract class ProfileRemoteDataSource {
  /// Fetches the current authenticated client's profile.
  Future<ClientModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<ClientModel> getProfile() async {
    final response = await _apiConsumer.get(EndPoints.clientProfile);
    return ClientModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
