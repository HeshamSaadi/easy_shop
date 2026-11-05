import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_client_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';

/// Hand-written fake. Set [ordersResult] or [orderResult] before the call.
class FakeOrdersRepository implements OrdersRepository {
  Either<Failure, List<OrderEntity>> ordersResult = const Right([]);
  Either<Failure, OrderEntity> orderResult = Right(buildOrder());

  /// The code the last [getOrder] call received.
  String? requestedCode;

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async => ordersResult;

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String code) async {
    requestedCode = code;
    return orderResult;
  }
}

OrderEntity buildOrder({String code = 'ORDER001'}) {
  return OrderEntity(
    id: 1,
    code: code,
    totalPrice: 599,
    address: '45 El Tahrir Square, Cairo',
    paymentMethod: PaymentMethod.cash,
    status: 'pending',
    client: const OrderClientEntity(
      id: 1,
      name: 'Omar Hassan',
      email: 'omar@example.com',
      phone: '+201018765432',
    ),
    items: const [],
  );
}
