import 'package:easy_shop/features/admin/profile/data/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _uploaded = 'https://example.com/uploads/users/file.jpg';
const _default = 'https://example.com/assets/images/default.png';

Map<String, dynamic> _json({
  Object? id = 7,
  Object? latitude = 30.0444,
  Object? longitude = 31.2357,
  String commercialRegisterUrl = _uploaded,
  String taxCardUrl = _default,
}) {
  return {
    'id': id,
    'name': 'Ahmed Khalil',
    'email': 'ahmed@shop.com',
    'phone': '+201001234567',
    'national_id': '29801234567890',
    'business_name': 'Khalil Digital Store',
    'address': '18 El Nasr Road',
    'latitude': latitude,
    'longitude': longitude,
    'picture_url': _default,
    'commercial_register_url': commercialRegisterUrl,
    'tax_card_url': taxCardUrl,
  };
}

void main() {
  group('ProfileModel.fromJson', () {
    test('reads every field', () {
      final model = ProfileModel.fromJson(_json());

      expect(model.id, 7);
      expect(model.name, 'Ahmed Khalil');
      expect(model.email, 'ahmed@shop.com');
      expect(model.phone, '+201001234567');
      expect(model.nationalId, '29801234567890');
      expect(model.businessName, 'Khalil Digital Store');
      expect(model.address, '18 El Nasr Road');
      expect(model.latitude, 30.0444);
      expect(model.longitude, 31.2357);
    });

    test('reads latitude and longitude sent as numbers or as strings', () {
      final fromNumbers = ProfileModel.fromJson(
        _json(latitude: 30, longitude: 31),
      );
      final fromStrings = ProfileModel.fromJson(
        _json(latitude: '30.0444', longitude: '31.2357'),
      );

      expect(fromNumbers.latitude, 30.0);
      expect(fromNumbers.longitude, 31.0);
      expect(fromStrings.latitude, 30.0444);
      expect(fromStrings.longitude, 31.2357);
    });

    test('gives null for a missing or invalid location', () {
      final missing = ProfileModel.fromJson(
        _json(latitude: null, longitude: null),
      );
      final invalid = ProfileModel.fromJson(
        _json(latitude: 'abc', longitude: ''),
      );

      expect(missing.latitude, isNull);
      expect(missing.longitude, isNull);
      expect(invalid.latitude, isNull);
      expect(invalid.longitude, isNull);
    });

    test('reads the id when it is a string, and falls back to 0', () {
      expect(ProfileModel.fromJson(_json(id: '5')).id, 5);
      expect(ProfileModel.fromJson(_json(id: null)).id, 0);
    });

    test('uses empty strings when text fields are missing', () {
      final model = ProfileModel.fromJson(<String, dynamic>{'id': 1});

      expect(model.name, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.nationalId, '');
      expect(model.businessName, '');
      expect(model.pictureUrl, '');
      expect(model.address, isNull);
    });
  });

  group('ProfileModel.toEntity', () {
    test('copies the fields to the entity', () {
      final entity = ProfileModel.fromJson(_json()).toEntity();

      expect(entity.id, 7);
      expect(entity.name, 'Ahmed Khalil');
      expect(entity.businessName, 'Khalil Digital Store');
      expect(entity.address, '18 El Nasr Road');
      expect(entity.latitude, 30.0444);
      expect(entity.longitude, 31.2357);
    });

    test('marks a document as uploaded only for an uploaded file URL', () {
      final entity = ProfileModel.fromJson(_json()).toEntity();

      expect(entity.hasCommercialRegister, isTrue);
      expect(entity.hasTaxCard, isFalse);
    });

    test('hasLocation needs both latitude and longitude', () {
      final both = ProfileModel.fromJson(_json()).toEntity();
      final onlyLatitude = ProfileModel.fromJson(_json(longitude: null))
          .toEntity();
      final none = ProfileModel.fromJson(_json(latitude: null, longitude: null))
          .toEntity();

      expect(both.hasLocation, isTrue);
      expect(onlyLatitude.hasLocation, isFalse);
      expect(none.hasLocation, isFalse);
    });
  });
}
