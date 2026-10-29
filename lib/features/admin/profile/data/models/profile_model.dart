import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.businessName,
    required this.pictureUrl,
    required this.commercialRegisterUrl,
    required this.taxCardUrl,
    this.address,
    this.latitude,
    this.longitude,
  });

  static const String _uploadsSegment = '/uploads/users/';

  final int id;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String pictureUrl;
  final String commercialRegisterUrl;
  final String taxCardUrl;
  final String? address;
  final double? latitude;
  final double? longitude;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: _toInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      nationalId: json['national_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      pictureUrl: json['picture_url'] as String? ?? '',
      commercialRegisterUrl: json['commercial_register_url'] as String? ?? '',
      taxCardUrl: json['tax_card_url'] as String? ?? '',
      address: json['address'] as String?,
      latitude: _toDoubleOrNull(json['latitude']),
      longitude: _toDoubleOrNull(json['longitude']),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      nationalId: nationalId,
      businessName: businessName,
      pictureUrl: pictureUrl,
      address: address,
      latitude: latitude,
      longitude: longitude,
      hasCommercialRegister: commercialRegisterUrl.contains(_uploadsSegment),
      hasTaxCard: taxCardUrl.contains(_uploadsSegment),
    );
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double? _toDoubleOrNull(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
