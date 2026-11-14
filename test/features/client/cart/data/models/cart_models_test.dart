import 'package:easy_shop/features/client/cart/data/models/cart_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../cart_test_helpers.dart';

void main() {
  group('CartItemModel.fromJson', () {
    test('parses the quantity and the nested product', () {
      final item = CartItemModel.fromJson(cartItemJson(quantity: 2));

      expect(item.quantity, 2);
      expect(item.product.id, 32);
      expect(item.product.slug, 'samsung-a-24');
      expect(item.product.name, 'Samsung A24');
      expect(item.product.price, 150.0);
      expect(item.product.stock, 40);
      expect(item.product.categoryName, 'Mobile Phone');
      expect(item.product.imageUrl, 'https://example.com/a24.png');
      expect(item.product.isVisible, isTrue);
    });

    test('reads the store name only from admin.business_name', () {
      final item = CartItemModel.fromJson(cartItemJson());

      expect(item.product.storeName, 'Elbatal Store');
    });

    test('accepts numbers sent as strings', () {
      final json = {
        ...cartItemJson(
          product: cartProductJson(
            overrides: {'price': '150', 'quantity': '40', 'visible': '1'},
          ),
        ),
        'quantity': '3',
      };

      final item = CartItemModel.fromJson(json);

      expect(item.quantity, 3);
      expect(item.product.price, 150.0);
      expect(item.product.stock, 40);
      expect(item.product.isVisible, isTrue);
    });

    test('a hidden product is flagged as hidden', () {
      final item = CartItemModel.fromJson(
        cartItemJson(product: cartProductJson(overrides: {'visible': 0})),
      );

      expect(item.product.isVisible, isFalse);
      expect(item.isHidden, isTrue);
    });

    test('a missing admin gives an empty store name', () {
      final item = CartItemModel.fromJson(
        cartItemJson(product: cartProductJson(overrides: {'admin': null})),
      );

      expect(item.product.storeName, '');
    });

    test('a blank business name gives an empty store name', () {
      final item = CartItemModel.fromJson(
        cartItemJson(
          product: cartProductJson(
            overrides: {
              'admin': {'business_name': '   '},
            },
          ),
        ),
      );

      expect(item.product.storeName, '');
    });

    test('a missing category gives an empty category name', () {
      final item = CartItemModel.fromJson(
        cartItemJson(product: cartProductJson(overrides: {'category': null})),
      );

      expect(item.product.categoryName, '');
    });

    test('a missing product does not crash', () {
      final item = CartItemModel.fromJson({'quantity': 1});

      expect(item.quantity, 1);
      expect(item.product.id, 0);
      expect(item.product.name, '');
    });
  });
}
