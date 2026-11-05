import 'package:easy_shop/features/admin/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel.fromJson', () {
    test('reads all fields', () {
      final model = CategoryModel.fromJson({
        'id': 1,
        'name': 'Shoes',
        'slug': 'shoes',
        'description': 'All shoes',
      });

      expect(model.id, 1);
      expect(model.name, 'Shoes');
      expect(model.slug, 'shoes');
      expect(model.description, 'All shoes');
    });

    test('reads an id sent as a string', () {
      final model = CategoryModel.fromJson({
        'id': '7',
        'name': 'Bags',
        'slug': 'bags',
      });

      expect(model.id, 7);
    });

    test('description is null when missing, null, empty or spaces only', () {
      for (final value in <Object?>[null, '', '   ']) {
        final model = CategoryModel.fromJson({
          'id': 1,
          'name': 'A',
          'slug': 'a',
          'description': value,
        });
        expect(model.description, isNull);
      }

      final missing = CategoryModel.fromJson({
        'id': 1,
        'name': 'A',
        'slug': 'a',
      });
      expect(missing.description, isNull);
    });

    test('trims the description', () {
      final model = CategoryModel.fromJson({
        'id': 1,
        'name': 'A',
        'slug': 'a',
        'description': '  Nice  ',
      });

      expect(model.description, 'Nice');
    });

    test('missing name and slug become empty strings', () {
      final model = CategoryModel.fromJson({'id': 1});

      expect(model.name, '');
      expect(model.slug, '');
    });
  });
}
