import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

/// Hand-written fake: keeps the cart in memory and never uses the network.
/// Set a `...Failure` to make that call fail, and [setQuantityGate] to pause
/// `setQuantity` until the test completes it.
class FakeCartRepository implements CartRepository {
  FakeCartRepository({List<CartItemEntity> items = const []})
    : items = [...items];

  List<CartItemEntity> items;

  Failure? getCartFailure;
  Failure? setQuantityFailure;
  Failure? removeFailure;
  Completer<void>? setQuantityGate;

  int getCartCalls = 0;
  final List<({int productId, int quantity})> setCalls = [];
  final List<int> removeCalls = [];

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async {
    getCartCalls++;
    final failure = getCartFailure;
    if (failure != null) return Left(failure);
    return Right([...items]);
  }

  @override
  Future<Either<Failure, Unit>> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    // Recorded before the pause, so a second request would show up too.
    setCalls.add((productId: productId, quantity: quantity));
    await setQuantityGate?.future;

    final failure = setQuantityFailure;
    if (failure != null) return Left(failure);

    items = [
      for (final item in items)
        item.product.id == productId
            ? CartItemEntity(product: item.product, quantity: quantity)
            : item,
    ];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> removeFromCart(int productId) async {
    removeCalls.add(productId);
    final failure = removeFailure;
    if (failure != null) return Left(failure);

    items = items.where((item) => item.product.id != productId).toList();
    return const Right(unit);
  }
}
