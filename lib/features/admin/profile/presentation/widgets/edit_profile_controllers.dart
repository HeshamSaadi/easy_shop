import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class EditProfileControllers {
  EditProfileControllers(ProfileEntity profile)
    : name = TextEditingController(text: profile.name),
      email = TextEditingController(text: profile.email),
      phone = TextEditingController(text: profile.phone),
      nationalId = TextEditingController(text: profile.nationalId),
      businessName = TextEditingController(text: profile.businessName),
      address = TextEditingController(text: profile.address);

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController nationalId;
  final TextEditingController businessName;
  final TextEditingController address;

  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    nationalId.dispose();
    businessName.dispose();
    address.dispose();
  }
}
