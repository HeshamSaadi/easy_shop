import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';

sealed class OrdersState {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// An empty [orders] list is the "empty" screen, not a separate state.
class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders, {this.actionError});

  final List<OrderEntity> orders;

  /// Set when a refresh failed. The list stays on screen and the UI shows
  /// this message in a SnackBar.
  final String? actionError;
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;
}
