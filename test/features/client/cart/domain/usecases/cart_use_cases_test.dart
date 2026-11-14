import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/remove_from_cart.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../cart_test_helpers.dart';
import '../../fake_cart_repository.dart';

void main() {
  late FakeCartRepository repository;

  setUp(() => repository = FakeCartRepository());

  group('GetCart', () {
    test('returns the cart items', () async {
      repository.items = [buildCartItem(), buildCartItem(productId: 2)];

      final items = rightOf(await GetCart(repository)());

      expect(items.map((item) => item.product.id), [1, 2]);
    });

    test('passes the failure through', () async {
      repository.getCartFailure = const Failure('No internet connection');

      final failure = leftOf(await GetCart(repository)());

      expect(failure.message, 'No internet connection');
    });
  });

  group('AddToCart', () {
    test('sends the product id and the new total quantity', () async {
      final result = await AddToCart(repository)(productId: 7, quantity: 4);

      expect(result, const Right<Failure, Unit>(unit));
      expect(repository.setCalls.single.productId, 7);
      expect(repository.setCalls.single.quantity, 4);
    });

    test('passes the failure through', () async {
      repository.setQuantityFailure = const Failure('Server error');

      final failure = leftOf(
        await AddToCart(repository)(productId: 7, quantity: 4),
      );

      expect(failure.message, 'Server error');
    });
  });

  group('RemoveFromCart', () {
    test('sends the product id', () async {
      final result = await RemoveFromCart(repository)(7);

      expect(result, const Right<Failure, Unit>(unit));
      expect(repository.removeCalls, [7]);
    });

    test('passes the failure through', () async {
      repository.removeFailure = const Failure('Server error');

      final failure = leftOf(await RemoveFromCart(repository)(7));

      expect(failure.message, 'Server error');
    });
  });
}
