import 'package:easy_shop/features/admin/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit({required this._getOrderDetails, required this.code})
    : super(const OrderDetailsInitial());

  final GetOrderDetails _getOrderDetails;

  /// Orders are addressed by code, not by id.
  final String code;

  Future<void> load() async {
    emit(const OrderDetailsLoading());
    final result = await _getOrderDetails(code);
    result.fold(
      (failure) => emit(OrderDetailsError(failure.message)),
      (order) => emit(OrderDetailsLoaded(order)),
    );
  }
}
