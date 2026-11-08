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
}
