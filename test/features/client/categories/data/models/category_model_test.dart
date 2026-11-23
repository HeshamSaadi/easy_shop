import 'package:easy_shop/features/client/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel.fromJson', () {
    test('reads every field', () {
      final model = CategoryModel.fromJson({
        'id': 5,
        'name': 'Mobile Phone',
        'slug': 'mobile-phone',
        'description': 'Phones and tablets',
        'created_at': '2026-11-06T11:27:57.000000Z',
      });

      expect(model.id, 5);
      expect(model.name, 'Mobile Phone');
      expect(model.slug, 'mobile-phone');
      expect(model.description, 'Phones and tablets');
    });

    test('accepts the id as a string', () {
      final model = CategoryModel.fromJson({'id': '7', 'name': 'A'});

      expect(model.id, 7);
    });

    test('a null description stays null', () {
      final model = CategoryModel.fromJson({'id': 1, 'description': null});

      expect(model.description, isNull);
    });

    test('an empty or blank description becomes null', () {
      expect(
        CategoryModel.fromJson({'id': 1, 'description': ''}).description,
        isNull,
      );
      expect(
        CategoryModel.fromJson({'id': 1, 'description': '   '}).description,
        isNull,
      );
    });

    test('trims the description', () {
      final model = CategoryModel.fromJson({'id': 1, 'description': ' Hi '});

      expect(model.description, 'Hi');
    });

    test('missing name and slug become empty strings, no crash', () {
      final model = CategoryModel.fromJson({'id': 1});

      expect(model.name, '');
      expect(model.slug, '');
    });
  });
}
