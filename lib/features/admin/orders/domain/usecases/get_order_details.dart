import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';

class GetOrderDetails {
  const GetOrderDetails(this._repository);

  final OrdersRepository _repository;

  Future<Either<Failure, OrderEntity>> call(String code) {
    return _repository.getOrder(code);
  }
}
