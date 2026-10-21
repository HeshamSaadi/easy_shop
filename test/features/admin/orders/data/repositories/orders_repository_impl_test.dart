import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/orders/data/datasources/orders_remote_data_source.dart';
import 'package:easy_shop/features/admin/orders/data/models/order_model.dart';
import 'package:easy_shop/features/admin/orders/data/repositories/orders_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../order_json_fixture.dart';

/// Hand-written fake, like the auth tests. Throws [error] when it is set.
class _FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  _FakeOrdersRemoteDataSource({this.orders = const [], this.error});

  final List<OrderModel> orders;
  final Object? error;

  @override
  Future<List<OrderModel>> getOrders() async {
    final failure = error;
    if (failure != null) throw failure;
    return orders;
  }

  @override
  Future<OrderModel> getOrder(String code) async {
    final failure = error;
    if (failure != null) throw failure;
    return orders.firstWhere((order) => order.code == code);
  }
}

void main() {
  final order = OrderModel.fromJson(orderJson());

  test('getOrders returns the orders on success', () async {
    final repository = OrdersRepositoryImpl(
      _FakeOrdersRemoteDataSource(orders: [order]),
    );

    final result = await repository.getOrders();

    result.fold(
      (_) => fail('Expected Right'),
      (orders) => expect(orders.single.code, '0D8CKBZJ'),
    );
  });

  test('getOrder returns the order with that code', () async {
    final repository = OrdersRepositoryImpl(
      _FakeOrdersRemoteDataSource(orders: [order]),
    );

    final result = await repository.getOrder('0D8CKBZJ');

    result.fold(
      (_) => fail('Expected Right'),
      (found) => expect(found.client.name, 'Omar Hassan'),
    );
  });

  test('an app exception becomes a Failure', () async {
    final repository = OrdersRepositoryImpl(
      _FakeOrdersRemoteDataSource(error: const ServerException()),
    );

    final result = await repository.getOrders();

    expect(result.isLeft(), isTrue);
  });

  test('an unexpected error becomes a Failure and does not crash', () async {
    final repository = OrdersRepositoryImpl(
      _FakeOrdersRemoteDataSource(error: StateError('boom')),
    );

    final result = await repository.getOrder('0D8CKBZJ');

    expect(result.isLeft(), isTrue);
  });
}
