import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/admin/orders/data/datasources/orders_remote_data_source.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() {
    return guardedCall(_remote.getOrders);
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String code) {
    return guardedCall(() => _remote.getOrder(code));
  }
}
