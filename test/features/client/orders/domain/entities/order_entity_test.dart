import 'package:flutter_test/flutter_test.dart';

import '../../client_orders_test_helpers.dart';

void main() {
  group('OrderEntity', () {
    test('hasLocation needs both coordinates', () {
      expect(buildOrder().hasLocation, isTrue);
      expect(buildOrder(latitude: null).hasLocation, isFalse);
      expect(buildOrder(longitude: null).hasLocation, isFalse);
    });

    test('isPending ignores case and spaces', () {
      expect(buildOrder(status: ' Pending ').isPending, isTrue);
      expect(buildOrder(status: 'processing').isPending, isFalse);
    });
  });
}
