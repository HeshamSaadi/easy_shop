/// Represents a client user in the system.
///
/// Contains all client information including personal details,
/// delivery address, and location coordinates.
class ClientEntity {
  const ClientEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
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
  final String? latitude;
  final String? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
}
