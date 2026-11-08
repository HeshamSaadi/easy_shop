class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? picturePath;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    this.address,
    this.latitude,
    this.longitude,
    this.picturePath,
  });
}
