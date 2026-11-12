import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/repositories/orders_repository.dart';

class GetOrders {
  const GetOrders(this._repository);

  final OrdersRepository _repository;

  /// Newest first. The server's order is not documented, so we sort here.
  Future<Either<Failure, List<OrderEntity>>> call() async {
    final result = await _repository.getOrders();
    return result.map((orders) => [...orders]..sort(_newestFirst));
  }

  static int _newestFirst(OrderEntity a, OrderEntity b) {
    final first = a.createdAt;
    final second = b.createdAt;
    if (first == null && second == null) return 0;
    if (first == null) return 1;
    if (second == null) return -1;
    return second.compareTo(first);
  }
}
