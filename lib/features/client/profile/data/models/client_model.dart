import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/profile/domain/entities/client_entity.dart';

/// Data model for client profile.
///
/// Handles JSON serialization/deserialization for client data
/// from API responses.
class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.createdAt,
    required super.updatedAt,
    super.pictureUrl,
    super.address,
    super.latitude,
    super.longitude,
  });

  /// Creates a [ClientModel] from JSON map.
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      pictureUrl: json['picture_url'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'picture_url': pictureUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
