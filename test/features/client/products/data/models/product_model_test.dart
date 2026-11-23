import 'package:easy_shop/features/client/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../product_test_helpers.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('reads every field', () {
      final model = ProductModel.fromJson(clientProductJson());

      expect(model.id, 32);
      expect(model.name, 'Samsung A24');
      expect(model.slug, 'samsung-a-24');
      expect(model.price, 150);
      expect(model.stock, 12);
      expect(model.categoryId, 5);
      expect(model.categoryName, 'Mobile Phone');
      expect(model.isVisible, isTrue);
      expect(model.imageUrl, 'https://example.com/a24.png');
      expect(model.description, '6.5" Super AMOLED display');
    });

    test('reads only the store name from the private admin object', () {
      final model = ProductModel.fromJson(clientProductJson());

      expect(model.storeName, 'Elbatal Store');
    });

    test('visible 0 means hidden', () {
      final model = ProductModel.fromJson(
        clientProductJson(overrides: {'visible': 0}),
      );

      expect(model.isVisible, isFalse);
    });

    test('accepts numbers sent as strings', () {
      final model = ProductModel.fromJson(
        clientProductJson(
          overrides: {'price': '150.5', 'quantity': '3', 'category_id': '9'},
        ),
      );

      expect(model.price, 150.5);
      expect(model.stock, 3);
      expect(model.categoryId, 9);
    });

    test('an empty or null description becomes null', () {
      expect(
        ProductModel.fromJson(clientProductJson(overrides: {'description': ''}))
            .description,
        isNull,
      );
      expect(
        ProductModel.fromJson(
          clientProductJson(overrides: {'description': null}),
        ).description,
        isNull,
      );
    });

    test('a missing category and admin give empty names, no crash', () {
      final json = clientProductJson()
        ..remove('category')
        ..remove('admin');

      final model = ProductModel.fromJson(json);

      expect(model.categoryName, '');
      expect(model.storeName, '');
    });

    test('a number in a text field does not throw', () {
      final model = ProductModel.fromJson(
        clientProductJson(overrides: {'name': 123}),
      );

      expect(model.name, '123');
    });

    test('inStock is false at stock 0', () {
      final model = ProductModel.fromJson(
        clientProductJson(overrides: {'quantity': 0}),
      );

      expect(model.inStock, isFalse);
    });
  });
}
