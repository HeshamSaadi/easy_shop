import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/remove_from_cart.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({
    required this._getCart,
    required this._addToCart,
    required this._removeFromCart,
  }) : super(const CartInitial());

  final GetCart _getCart;
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;

  Future<void> load() async {
    emit(const CartLoading());
    final result = await _getCart();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (items) => emit(CartLoaded(items)),
    );
  }

  /// Pull to refresh: keeps the old list on screen while loading.
  Future<void> refresh() async {
    final result = await _getCart();
    result.fold(
      (failure) => _keepListWithError(failure.message),
      _replaceItems,
    );
  }

  /// The server replaces the quantity, so we send the new total.
  /// Above the stock nothing is sent (the order would be rejected).
  Future<void> increase(CartItemEntity item) async {
    final next = item.quantity + 1;
    if (next > item.product.stock) return;
    await _run(
      item.product.id,
      () => _addToCart(productId: item.product.id, quantity: next),
    );
  }

  /// A quantity below 1 is rejected by the server (422), so it becomes a
  /// remove. An item above stock comes down to the stock first.
  Future<void> decrease(CartItemEntity item) async {
    final next = min(item.quantity - 1, item.product.stock);
    if (next < 1) {
      await remove(item.product.id);
      return;
    }
    await _run(
      item.product.id,
      () => _addToCart(productId: item.product.id, quantity: next),
    );
  }

  Future<void> remove(int productId) {
    return _run(productId, () => _removeFromCart(productId));
  }

  /// Runs one change on one product, then refetches the cart.
  /// A product with a request in flight ignores further taps.
  Future<void> _run(
    int productId,
    Future<Either<Failure, Unit>> Function() action,
  ) async {
    final current = state;
    if (current is! CartLoaded || current.isBusy(productId)) return;

    emit(
      current.copyWith(busyProductIds: {...current.busyProductIds, productId}),
    );

    final result = await action();
    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null) {
      _finish(productId, error: failure.message);
      return;
    }

    final cart = await _getCart();
    cart.fold(
      (f) => _finish(productId, error: f.message),
      (items) => _finish(productId, items: items),
    );
  }

  /// Reads the state again, because other products may have changed
  /// while this request was running.
  void _finish(int productId, {List<CartItemEntity>? items, String? error}) {
    final current = state;
    if (current is! CartLoaded) return;
    emit(
      current.copyWith(
        items: items,
        busyProductIds: {...current.busyProductIds}..remove(productId),
        actionError: error,
      ),
    );
  }

  void _replaceItems(List<CartItemEntity> items) {
    final current = state;
    final busy = current is CartLoaded ? current.busyProductIds : <int>{};
    emit(CartLoaded(items, busyProductIds: busy));
  }

  void _keepListWithError(String message) {
    final current = state;
    if (current is CartLoaded) {
      emit(current.copyWith(actionError: message));
    } else {
      emit(CartError(message));
    }
  }
}
