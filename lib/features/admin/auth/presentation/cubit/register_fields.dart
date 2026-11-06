import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';

abstract final class RegisterFields {
  static const name = 'name';
  static const email = 'email';
  static const phone = 'phone';
  static const nationalId = 'national_id';
  static const businessName = 'business_name';
  static const address = 'address';
  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const commercialRegister = 'commercial_register';
  static const taxCard = 'tax_card';
  static const picture = 'picture';
  static const password = 'password';
  static const passwordConfirmation = 'password_confirmation';

  static const Map<String, RegisterStep> stepOf = {
    name: RegisterStep.personal,
    email: RegisterStep.personal,
    phone: RegisterStep.personal,
    nationalId: RegisterStep.personal,
    businessName: RegisterStep.business,
    address: RegisterStep.business,
    latitude: RegisterStep.business,
    longitude: RegisterStep.business,
    commercialRegister: RegisterStep.business,
    taxCard: RegisterStep.business,
    picture: RegisterStep.security,
    password: RegisterStep.security,
    passwordConfirmation: RegisterStep.security,
  };
}
