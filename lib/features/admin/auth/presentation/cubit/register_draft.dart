import 'package:easy_shop/features/admin/auth/domain/params/register_params.dart';

class RegisterDraft {
  const RegisterDraft({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.nationalId = '',
    this.businessName = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.commercialRegisterPath,
    this.taxCardPath,
    this.picturePath,
  });

  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? commercialRegisterPath;
  final String? taxCardPath;
  final String? picturePath;

  bool get hasLocation => latitude != null && longitude != null;

  RegisterDraft copyWith({
    String? name,
    String? email,
    String? phone,
    String? nationalId,
    String? businessName,
    String? address,
    double? latitude,
    double? longitude,
    String? commercialRegisterPath,
    String? taxCardPath,
    String? picturePath,
  }) {
    return RegisterDraft(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      commercialRegisterPath:
          commercialRegisterPath ?? this.commercialRegisterPath,
      taxCardPath: taxCardPath ?? this.taxCardPath,
      picturePath: picturePath ?? this.picturePath,
    );
  }

  RegisterParams toParams({
    required String password,
    required String passwordConfirmation,
  }) {
    return RegisterParams(
      name: name,
      email: email,
      phone: phone,
      nationalId: nationalId,
      businessName: businessName,
      password: password,
      passwordConfirmation: passwordConfirmation,
      address: address.isEmpty ? null : address,
      latitude: latitude,
      longitude: longitude,
      picturePath: picturePath,
      commercialRegisterPath: commercialRegisterPath,
      taxCardPath: taxCardPath,
    );
  }
}
