import 'package:easy_shop/features/client/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/order_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit({required this.code, required this._getOrderDetails})
    : super(const OrderDetailsInitial());

  /// Orders are addressed by code, not by id.
  final String code;
  final GetOrderDetails _getOrderDetails;

  Future<void> load() async {
    emit(const OrderDetailsLoading());
    final result = await _getOrderDetails(code);
    if (isClosed) return;

    result.fold(
      (failure) => emit(OrderDetailsError(failure.message)),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }
}
