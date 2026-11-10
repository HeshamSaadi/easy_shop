/// A client of the store: personal details and the saved delivery location.
class ClientEntity {
  const ClientEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.pictureUrl,
    this.address,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String? pictureUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
}
