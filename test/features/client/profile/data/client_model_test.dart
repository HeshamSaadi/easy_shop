import 'package:easy_shop/features/client/profile/data/models/client_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = {
    'id': 1,
    'name': 'Ahmed',
    'email': 'ahmed@example.com',
    'phone': '+201000000000',
  };

  test('reads coordinates sent as numbers', () {
    final model = ClientModel.fromJson({
      ...base,
      'latitude': 30.05,
      'longitude': 31.23,
    });

    expect(model.latitude, 30.05);
    expect(model.longitude, 31.23);
  });

  test('reads coordinates sent as strings', () {
    final model = ClientModel.fromJson({
      ...base,
      'latitude': '30.05',
      'longitude': '31.23',
    });

    expect(model.latitude, 30.05);
    expect(model.longitude, 31.23);
  });

  test('keeps coordinates null when the server sends null', () {
    final model = ClientModel.fromJson({
      ...base,
      'latitude': null,
      'longitude': null,
    });

    expect(model.latitude, isNull);
    expect(model.longitude, isNull);
  });

  test('reads every field of a full profile', () {
    final model = ClientModel.fromJson({
      ...base,
      'address': '123 Tahrir Square',
      'latitude': 30.05,
      'longitude': 31.23,
      'picture_url': 'https://host/uploads/clients/me.jpg',
    });

    expect(model.id, 1);
    expect(model.name, 'Ahmed');
    expect(model.email, 'ahmed@example.com');
    expect(model.phone, '+201000000000');
    expect(model.address, '123 Tahrir Square');
    expect(model.pictureUrl, 'https://host/uploads/clients/me.jpg');
  });

  test('keeps the optional fields null when the keys are missing', () {
    final model = ClientModel.fromJson(base);

    expect(model.address, isNull);
    expect(model.pictureUrl, isNull);
    expect(model.latitude, isNull);
    expect(model.longitude, isNull);
  });

  test('uses an empty text when a required text is missing or null', () {
    final model = ClientModel.fromJson({'id': 1, 'name': null, 'email': null});

    expect(model.name, '');
    expect(model.email, '');
    expect(model.phone, '');
  });
}
