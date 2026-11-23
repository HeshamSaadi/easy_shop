import 'package:easy_shop/features/client/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared by the whole client shell, so the list can be refreshed from
/// outside after an order is placed.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required this._getOrders}) : super(const OrdersInitial());

  final GetOrders _getOrders;

  Future<void> load() async {
    emit(const OrdersLoading());
    final result = await _getOrders();
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Pull to refresh: keeps the old list on screen while loading.
  Future<void> refresh() async {
    final result = await _getOrders();
    result.fold(
      (failure) => _keepListWithError(failure.message),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  void _keepListWithError(String message) {
    final current = state;
    if (current is OrdersLoaded) {
      emit(OrdersLoaded(current.orders, actionError: message));
    } else {
      emit(OrdersError(message));
    }
  }
}
