import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

/// Client profile as the API returns it.
class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.pictureUrl,
    super.address,
    super.latitude,
    super.longitude,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      pictureUrl: json['picture_url'] as String?,
      address: json['address'] as String?,
      latitude: parseNullableDouble(json['latitude']),
      longitude: parseNullableDouble(json['longitude']),
    );
  }
}
