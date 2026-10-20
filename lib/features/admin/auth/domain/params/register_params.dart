class RegisterParams {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.businessName,
    required this.password,
    required this.passwordConfirmation,
    this.address,
    this.latitude,
    this.longitude,
    this.picturePath,
    this.commercialRegisterPath,
    this.taxCardPath,
  });

  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String password;
  final String passwordConfirmation;
  final String? address;
  final double? latitude;
  final double? longitude;

  final String? picturePath;
  final String? commercialRegisterPath;
  final String? taxCardPath;
}
