import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';

class GetOrders {
  const GetOrders(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, List<OrderEntity>>> call() {
    return _repository.getOrders();
  }
}
