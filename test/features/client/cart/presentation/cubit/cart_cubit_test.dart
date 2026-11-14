import 'dart:async';

import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/remove_from_cart.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../cart_test_helpers.dart';
import '../../fake_cart_repository.dart';

void main() {
  late FakeCartRepository repository;
  late CartCubit cubit;

  setUp(() {
    repository = FakeCartRepository();
    cubit = CartCubit(
      getCart: GetCart(repository),
      addToCart: AddToCart(repository),
      removeFromCart: RemoveFromCart(repository),
    );
  });

  tearDown(() => cubit.close());

  /// Loads [items] and returns them as the screen would see them.
  Future<List<CartItemEntity>> loadWith(List<CartItemEntity> items) async {
    repository.items = [...items];
    await cubit.load();
    return (cubit.state as CartLoaded).items;
  }

  test('starts in CartInitial', () {
    expect(cubit.state, isA<CartInitial>());
  });

  group('load', () {
    test('emits Loading then Loaded with the items', () async {
      repository.items = [buildCartItem(), buildCartItem(productId: 2)];

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CartLoading>(),
          isA<CartLoaded>().having((s) => s.items.length, 'items', 2),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('an empty cart is Loaded with an empty list', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CartLoading>(),
          isA<CartLoaded>().having((s) => s.items, 'items', isEmpty),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('emits Loading then Error with the failure message', () async {
      repository.getCartFailure = const Failure('No internet connection');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CartLoading>(),
          isA<CartError>().having(
            (s) => s.message,
            'message',
            'No internet connection',
          ),
        ]),
      );

      await cubit.load();
      await expectation;
    });
  });

  group('refresh', () {
    test('replaces the items without showing Loading', () async {
      await loadWith([buildCartItem()]);
      repository.items = [buildCartItem(), buildCartItem(productId: 2)];

      final expectation = expectLater(
        cubit.stream,
        emits(isA<CartLoaded>().having((s) => s.items.length, 'items', 2)),
      );

      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh keeps the items and sets actionError', () async {
      await loadWith([buildCartItem()]);
      repository.getCartFailure = const Failure('Server error');

      final expectation = expectLater(
        cubit.stream,
        emits(
          isA<CartLoaded>()
              .having((s) => s.items.length, 'items', 1)
              .having((s) => s.actionError, 'actionError', 'Server error'),
        ),
      );

      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh before anything was loaded emits Error', () async {
      repository.getCartFailure = const Failure('Server error');

      final expectation = expectLater(cubit.stream, emits(isA<CartError>()));

      await cubit.refresh();
      await expectation;
    });
  });

  group('increase', () {
    test('sends the new total, then refetches the cart', () async {
      final items = await loadWith([buildCartItem(quantity: 2, stock: 10)]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CartLoaded>().having((s) => s.isBusy(1), 'busy', isTrue),
          isA<CartLoaded>()
              .having((s) => s.isBusy(1), 'busy', isFalse)
              .having((s) => s.items.single.quantity, 'quantity', 3)
              .having((s) => s.actionError, 'actionError', isNull),
        ]),
      );

      await cubit.increase(items.single);
      await expectation;

      expect(repository.setCalls.single.productId, 1);
      expect(repository.setCalls.single.quantity, 3);
    });

    test('does nothing at the stock limit', () async {
      final items = await loadWith([buildCartItem(quantity: 3, stock: 3)]);

      await cubit.increase(items.single);

      expect(repository.setCalls, isEmpty);
      expect(cubit.state, isA<CartLoaded>());
    });

    test('is ignored before the cart is loaded', () async {
      await cubit.increase(buildCartItem());

      expect(repository.setCalls, isEmpty);
      expect(cubit.state, isA<CartInitial>());
    });
  });

  group('decrease', () {
    test('sends the new total when the quantity stays above 1', () async {
      final items = await loadWith([buildCartItem(quantity: 3)]);

      await cubit.decrease(items.single);

      expect(repository.setCalls.single.quantity, 2);
      expect(repository.removeCalls, isEmpty);
    });

    test('at quantity 1 removes the product (the server rejects 0)', () async {
      final items = await loadWith([buildCartItem(quantity: 1)]);

      await cubit.decrease(items.single);

      expect(repository.setCalls, isEmpty);
      expect(repository.removeCalls, [1]);
    });

    test('an item above the stock comes down to the stock', () async {
      final items = await loadWith([buildCartItem(quantity: 5, stock: 3)]);

      await cubit.decrease(items.single);

      expect(repository.setCalls.single.quantity, 3);
    });

    test('an item with no stock left is removed', () async {
      final items = await loadWith([buildCartItem(quantity: 1, stock: 0)]);

      await cubit.decrease(items.single);

      expect(repository.removeCalls, [1]);
    });
  });

  group('remove', () {
    test('removes the product and refetches the cart', () async {
      await loadWith([buildCartItem(), buildCartItem(productId: 2)]);

      await cubit.remove(1);

      expect(repository.removeCalls, [1]);
      final state = cubit.state as CartLoaded;
      expect(state.items.map((item) => item.product.id), [2]);
      expect(state.isBusy(1), isFalse);
    });
  });

  group('no double submit', () {
    test('a product with a request in flight ignores more taps', () async {
      final items = await loadWith([buildCartItem(quantity: 1)]);
      final gate = Completer<void>();
      repository.setQuantityGate = gate;

      final first = cubit.increase(items.single);
      final second = cubit.increase(items.single);
      gate.complete();
      await Future.wait([first, second]);

      expect(repository.setCalls, hasLength(1));
    });

    test('two different products can change at the same time', () async {
      final items = await loadWith([
        buildCartItem(),
        buildCartItem(productId: 2),
      ]);
      final gate = Completer<void>();
      repository.setQuantityGate = gate;

      final first = cubit.increase(items[0]);
      final second = cubit.increase(items[1]);

      final busy = (cubit.state as CartLoaded).busyProductIds;
      expect(busy, {1, 2});

      gate.complete();
      await Future.wait([first, second]);

      expect(repository.setCalls, hasLength(2));
      expect((cubit.state as CartLoaded).busyProductIds, isEmpty);
    });
  });

  group('failed actions', () {
    test('a failed change keeps the list and sets actionError', () async {
      final items = await loadWith([buildCartItem(quantity: 2)]);
      repository.setQuantityFailure = const Failure('Server error');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CartLoaded>().having((s) => s.isBusy(1), 'busy', isTrue),
          isA<CartLoaded>()
              .having((s) => s.isBusy(1), 'busy', isFalse)
              .having((s) => s.items.single.quantity, 'quantity', 2)
              .having((s) => s.actionError, 'actionError', 'Server error'),
        ]),
      );

      await cubit.increase(items.single);
      await expectation;

      // No refetch after a failed change: only the first load called it.
      expect(repository.getCartCalls, 1);
    });

    test('a failed refetch after a change sets actionError', () async {
      final items = await loadWith([buildCartItem(quantity: 2)]);
      repository.getCartFailure = const Failure('No internet connection');

      await cubit.increase(items.single);

      final state = cubit.state as CartLoaded;
      expect(state.actionError, 'No internet connection');
      expect(state.isBusy(1), isFalse);
    });

    test('a failed remove keeps the product in the list', () async {
      await loadWith([buildCartItem()]);
      repository.removeFailure = const Failure('Server error');

      await cubit.remove(1);

      final state = cubit.state as CartLoaded;
      expect(state.items, hasLength(1));
      expect(state.actionError, 'Server error');
    });
  });

  group('CartLoaded', () {
    test('total is the sum of the line totals', () {
      final state = CartLoaded([
        buildCartItem(price: 150, quantity: 2),
        buildCartItem(productId: 2, price: 600),
      ]);

      expect(state.total, 900);
    });

    test('hasProblems is true for a hidden item', () {
      final state = CartLoaded([buildCartItem(isVisible: false)]);

      expect(state.hasProblems, isTrue);
    });

    test('hasProblems is true for an item above the stock', () {
      final state = CartLoaded([buildCartItem(quantity: 5, stock: 3)]);

      expect(state.hasProblems, isTrue);
    });

    test('hasProblems is false for a normal cart', () {
      final state = CartLoaded([buildCartItem(quantity: 2, stock: 10)]);

      expect(state.hasProblems, isFalse);
    });

    test('copyWith clears the old actionError unless a new one is given', () {
      const state = CartLoaded([], actionError: 'Server error');

      expect(state.copyWith().actionError, isNull);
      expect(state.copyWith(actionError: 'Other').actionError, 'Other');
    });
  });
}
