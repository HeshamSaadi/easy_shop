import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';

sealed class OrderDetailsState {
  const OrderDetailsState();
}

class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();
}

class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

class OrderDetailsLoaded extends OrderDetailsState {
  const OrderDetailsLoaded(this.order);

  final OrderEntity order;
}

class OrderDetailsError extends OrderDetailsState {
  const OrderDetailsError(this.message);

  final String message;
}
