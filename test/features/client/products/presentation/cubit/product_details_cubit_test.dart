import 'dart:async';

import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/client/products/presentation/constants/product_details_strings.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_cubit.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cart/cart_test_helpers.dart';
import '../../../cart/fake_cart_repository.dart';
import '../../../home/fake_catalog_repositories.dart';
import '../../product_test_helpers.dart';

void main() {
  late FakeCartRepository cart;
  late ProductDetailsCubit cubit;

  /// Builds the Cubit for a product with [stock] units and loads it.
  Future<void> loadProduct({int stock = 10, String slug = 'product-1'}) async {
    cubit = ProductDetailsCubit(
      slug: slug,
      getProductDetails: GetProductDetails(
        FakeProductRepository(products: [buildProduct(stock: stock)]),
      ),
      getCart: GetCart(cart),
      addToCart: AddToCart(cart),
    );
    await cubit.load();
  }

  ProductDetailsLoaded loaded() => cubit.state as ProductDetailsLoaded;

  setUp(() => cart = FakeCartRepository());

  tearDown(() => cubit.close());

  group('load', () {
    test('emits Loading and then Loaded with the product', () async {
      cubit = ProductDetailsCubit(
        slug: 'product-1',
        getProductDetails: GetProductDetails(
          FakeProductRepository(products: [buildProduct()]),
        ),
        getCart: GetCart(cart),
        addToCart: AddToCart(cart),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsLoaded>()
              .having((s) => s.product.slug, 'slug', 'product-1')
              .having((s) => s.quantity, 'quantity', 1)
              .having((s) => s.status, 'status', AddToCartStatus.idle),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('an unknown slug emits Error with the failure message', () async {
      await loadProduct(slug: 'does-not-exist');

      expect(cubit.state, isA<ProductDetailsError>());
      expect((cubit.state as ProductDetailsError).message, 'Product not found');
    });
  });

  group('quantity', () {
    test('increase stops at the stock', () async {
      await loadProduct(stock: 2);

      cubit.increase();
      cubit.increase();
      cubit.increase();

      expect(loaded().quantity, 2);
    });

    test('decrease stops at 1', () async {
      await loadProduct();

      cubit.decrease();

      expect(loaded().quantity, 1);
    });

    test('both are ignored before the product is loaded', () {
      cubit = ProductDetailsCubit(
        slug: 'product-1',
        getProductDetails: GetProductDetails(FakeProductRepository()),
        getCart: GetCart(cart),
        addToCart: AddToCart(cart),
      );

      cubit.increase();
      cubit.decrease();

      expect(cubit.state, isA<ProductDetailsLoading>());
    });

    test('changing the quantity after "Added" goes back to idle', () async {
      await loadProduct();
      await cubit.addToCart();
      expect(loaded().status, AddToCartStatus.added);

      cubit.increase();

      expect(loaded().status, AddToCartStatus.idle);
      expect(loaded().quantity, 2);
    });
  });

  group('addToCart', () {
    test('sends the chosen quantity and ends as added', () async {
      await loadProduct();
      cubit.increase();
      cubit.increase();

      await cubit.addToCart();

      expect(cart.setCalls, [(productId: 1, quantity: 3)]);
      expect(loaded().status, AddToCartStatus.added);
      expect(loaded().actionError, isNull);
    });

    test(
      'sends the new total when the product is already in the cart',
      () async {
        cart.items = [buildCartItem(productId: 1, quantity: 4)];
        await loadProduct();
        cubit.increase();

        await cubit.addToCart();

        expect(cart.setCalls.single.quantity, 6);
      },
    );

    test('the total never goes above the stock', () async {
      cart.items = [buildCartItem(productId: 1, quantity: 4, stock: 5)];
      await loadProduct(stock: 5);
      cubit.increase();
      cubit.increase();

      await cubit.addToCart();

      expect(cart.setCalls.single.quantity, 5);
    });

    test(
      'an item already at the stock is not sent and shows the message',
      () async {
        cart.items = [buildCartItem(productId: 1, quantity: 5, stock: 5)];
        await loadProduct(stock: 5);

        await cubit.addToCart();

        expect(cart.setCalls, isEmpty);
        expect(loaded().actionError, ProductDetailsStrings.alreadyMax);
        expect(loaded().status, AddToCartStatus.idle);
      },
    );

    test('a failed cart read sets actionError and sends nothing', () async {
      cart.getCartFailure = const Failure('No internet');
      await loadProduct();

      await cubit.addToCart();

      expect(cart.setCalls, isEmpty);
      expect(loaded().actionError, 'No internet');
      expect(loaded().status, AddToCartStatus.idle);
    });

    test('a failed save sets actionError and goes back to idle', () async {
      cart.setQuantityFailure = const Failure('Server error');
      await loadProduct();

      await cubit.addToCart();

      expect(loaded().actionError, 'Server error');
      expect(loaded().status, AddToCartStatus.idle);
    });

    test('a second tap while adding sends only one request', () async {
      cart.setQuantityGate = Completer<void>();
      await loadProduct();

      final firstTap = cubit.addToCart();
      await pumpEventQueue();
      expect(loaded().status, AddToCartStatus.adding);
      await cubit.addToCart();
      cart.setQuantityGate!.complete();
      await firstTap;

      expect(cart.setCalls, hasLength(1));
    });

    test(
      'a tap after "Added" does nothing until the quantity changes',
      () async {
        await loadProduct();
        await cubit.addToCart();

        await cubit.addToCart();

        expect(cart.setCalls, hasLength(1));
      },
    );

    test('an out of stock product cannot be added', () async {
      await loadProduct(stock: 0);

      await cubit.addToCart();

      expect(cart.getCartCalls, 0);
      expect(cart.setCalls, isEmpty);
      expect(loaded().status, AddToCartStatus.idle);
    });
  });

  test('does not emit Loaded after the Cubit is closed', () async {
    cubit = ProductDetailsCubit(
      slug: 'product-1',
      getProductDetails: GetProductDetails(
        FakeProductRepository(products: [buildProduct()]),
      ),
      getCart: GetCart(cart),
      addToCart: AddToCart(cart),
    );
    final states = <ProductDetailsState>[];
    final subscription = cubit.stream.listen(states.add);

    final loading = cubit.load();
    await cubit.close();
    await loading;
    await subscription.cancel();

    expect(states.whereType<ProductDetailsLoaded>(), isEmpty);
  });
}
