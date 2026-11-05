/// Parameters for updating client profile.
class UpdateProfileParams {
  const UpdateProfileParams({
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.picturePath,
  });

  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? picturePath;
}
