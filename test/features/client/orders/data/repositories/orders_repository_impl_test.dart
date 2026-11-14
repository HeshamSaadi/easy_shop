import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/orders/data/datasources/orders_remote_data_source.dart';
import 'package:easy_shop/features/client/orders/data/models/order_model.dart';
import 'package:easy_shop/features/client/orders/data/repositories/orders_repository_impl.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cart/cart_test_helpers.dart' show leftOf, rightOf;
import '../../client_orders_test_helpers.dart';

/// Hand-written fake. Throws [error] when it is set.
class _FakeOrdersRemoteDataSource implements OrdersRemoteDataSource {
  List<OrderModel> orders = [];
  Object? error;

  PlaceOrderParams? lastPlaced;
  String? lastCode;

  void _throwIfNeeded() {
    final failure = error;
    if (failure != null) throw failure;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    _throwIfNeeded();
    return orders;
  }

  @override
  Future<OrderModel> getOrder(String code) async {
    _throwIfNeeded();
    lastCode = code;
    return orders.firstWhere((order) => order.code == code);
  }

  @override
  Future<OrderModel> placeOrder(PlaceOrderParams params) async {
    _throwIfNeeded();
    lastPlaced = params;
    return orders.first;
  }
}

void main() {
  late _FakeOrdersRemoteDataSource remote;
  late OrdersRepositoryImpl repository;

  setUp(() {
    remote = _FakeOrdersRemoteDataSource()
      ..orders = [OrderModel.fromJson(clientOrderJson())];
    repository = OrdersRepositoryImpl(remote);
  });

  test('getOrders returns the orders on success', () async {
    final orders = rightOf(await repository.getOrders());

    expect(orders.single.code, '66D1BJIY');
    expect(orders.single.items, hasLength(2));
  });

  test('getOrder sends the code and returns that order', () async {
    final order = rightOf(await repository.getOrder('66D1BJIY'));

    expect(remote.lastCode, '66D1BJIY');
    expect(order.address, 'Cairo, Egypt');
  });

  test('placeOrder sends the params and returns the new order', () async {
    final params = buildPlaceOrderParams();

    final order = rightOf(await repository.placeOrder(params));

    expect(remote.lastPlaced, same(params));
    expect(order.code, '66D1BJIY');
  });

  test('an app exception becomes a Failure', () async {
    remote.error = const ServerException();

    final failure = leftOf(await repository.getOrders());

    expect(failure.message, const ServerException().message);
  });

  test('the 422 for a quantity above stock keeps its message', () async {
    remote.error = const BadRequestException(
      'The quantity.0 field must be less than or equal to 40.',
      statusCode: 422,
      fieldErrors: {
        'quantity.0': [
          'The quantity.0 field must be less than or equal to 40.',
        ],
      },
    );

    final failure = leftOf(
      await repository.placeOrder(buildPlaceOrderParams()),
    );

    expect(failure.statusCode, 422);
    expect(failure.message, contains('less than or equal to 40'));
    expect(failure.fieldErrors.keys, ['quantity.0']);
  });

  test('an unexpected error becomes a Failure and does not crash', () async {
    remote.error = StateError('boom');

    final failure = leftOf(await repository.getOrder('66D1BJIY'));

    expect(failure.message, const UnknownException().message);
  });
}
