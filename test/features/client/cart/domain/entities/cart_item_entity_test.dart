import 'package:flutter_test/flutter_test.dart';

import '../../cart_test_helpers.dart';

void main() {
  group('CartItemEntity', () {
    test('lineTotal is the product price times the quantity', () {
      final item = buildCartItem(price: 12.5, quantity: 3);

      expect(item.lineTotal, 37.5);
    });

    test('exceedsStock is true only above the stock', () {
      expect(buildCartItem(quantity: 5, stock: 3).exceedsStock, isTrue);
      expect(buildCartItem(quantity: 3, stock: 3).exceedsStock, isFalse);
    });

    test('isHidden follows the product visibility', () {
      expect(buildCartItem(isVisible: false).isHidden, isTrue);
      expect(buildCartItem().isHidden, isFalse);
    });
  });
}
