import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';
import 'package:easy_shop/features/client/orders/domain/repositories/orders_repository.dart';

/// A successful order also empties the whole server cart, so the caller must
/// reload the cart afterwards.
class PlaceOrder {
  const PlaceOrder(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call(PlaceOrderParams params) {
    return _repository.placeOrder(params);
  }
}
