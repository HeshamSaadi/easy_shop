import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';

sealed class CartState {
  const CartState();
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

/// An empty [items] list is the "empty cart" screen, not a separate state.
class CartLoaded extends CartState {
  const CartLoaded(
    this.items, {
    this.busyProductIds = const <int>{},
    this.actionError,
  });

  final List<CartItemEntity> items;

  /// Products with a request in flight. Their buttons are disabled.
  final Set<int> busyProductIds;

  /// Set when an action failed. The list stays on screen and the UI shows
  /// this message in a SnackBar.
  final String? actionError;

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// The server accepts hidden products and quantities above stock,
  /// so the app must not let the user check out with them.
  bool get hasProblems =>
      items.any((item) => item.isHidden || item.exceedsStock);

  bool isBusy(int productId) => busyProductIds.contains(productId);

  /// Every copy clears [actionError] unless a new one is passed, so a
  /// message is shown once.
  CartLoaded copyWith({
    List<CartItemEntity>? items,
    Set<int>? busyProductIds,
    String? actionError,
  }) {
    return CartLoaded(
      items ?? this.items,
      busyProductIds: busyProductIds ?? this.busyProductIds,
      actionError: actionError,
    );
  }
}

class CartError extends CartState {
  const CartError(this.message);

  final String message;
}
