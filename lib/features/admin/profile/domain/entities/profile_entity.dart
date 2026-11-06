class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.businessName,
    required this.pictureUrl,
    required this.hasCommercialRegister,
    required this.hasTaxCard,
    this.address,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String pictureUrl;
  final String? address;
  final double? latitude;
  final double? longitude;

  final bool hasCommercialRegister;
  final bool hasTaxCard;

  bool get hasLocation => latitude != null && longitude != null;
}
