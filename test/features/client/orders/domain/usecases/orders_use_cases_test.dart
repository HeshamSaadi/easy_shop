import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/place_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cart/cart_test_helpers.dart' show leftOf, rightOf;
import '../../client_orders_test_helpers.dart';

void main() {
  late FakeClientOrdersRepository repository;

  setUp(() => repository = FakeClientOrdersRepository());

  group('GetOrders', () {
    test('sorts the orders newest first', () async {
      final older = buildOrder(code: 'OLD', createdAt: DateTime.utc(2026, 11));
      final newer = buildOrder(
        code: 'NEW',
        createdAt: DateTime.utc(2026, 11, 5),
      );
      repository.ordersResult = Right([older, newer]);

      final orders = rightOf(await GetOrders(repository)());

      expect(orders.map((order) => order.code), ['NEW', 'OLD']);
    });

    test('puts an order with no date last', () async {
      final dated = buildOrder(
        code: 'DATED',
        createdAt: DateTime.utc(2026, 11),
      );
      final undated = buildOrder(code: 'NONE');
      repository.ordersResult = Right([undated, dated]);

      final orders = rightOf(await GetOrders(repository)());

      expect(orders.map((order) => order.code), ['DATED', 'NONE']);
    });

    test('does not change the list it received', () async {
      final source = [
        buildOrder(code: 'OLD', createdAt: DateTime.utc(2026, 11)),
        buildOrder(code: 'NEW', createdAt: DateTime.utc(2026, 11, 5)),
      ];
      repository.ordersResult = Right(source);

      await GetOrders(repository)();

      expect(source.first.code, 'OLD');
    });

    test('an empty list stays empty', () async {
      final orders = rightOf(await GetOrders(repository)());

      expect(orders, isEmpty);
    });

    test('passes the failure through', () async {
      repository.ordersResult = const Left(Failure('No internet connection'));

      final failure = leftOf(await GetOrders(repository)());

      expect(failure.message, 'No internet connection');
    });
  });

  group('GetOrderDetails', () {
    test('asks the repository for that code', () async {
      repository.orderResult = Right(buildOrder(code: 'ABC123'));

      final order = rightOf(await GetOrderDetails(repository)('ABC123'));

      expect(repository.requestedCode, 'ABC123');
      expect(order.code, 'ABC123');
    });

    test('passes the failure through', () async {
      repository.orderResult = const Left(Failure('Order is not found'));

      final failure = leftOf(await GetOrderDetails(repository)('NOPE'));

      expect(failure.message, 'Order is not found');
    });
  });

  group('PlaceOrder', () {
    test('sends the params to the repository and returns the order', () async {
      repository.placeResult = Right(buildOrder(code: 'NEWORDER'));
      final params = buildPlaceOrderParams();

      final order = rightOf(await PlaceOrder(repository)(params));

      expect(order.code, 'NEWORDER');
      expect(repository.placedParams.single, same(params));
    });

    test('passes the failure through', () async {
      repository.placeResult = const Left(Failure('Server error'));

      final failure = leftOf(
        await PlaceOrder(repository)(buildPlaceOrderParams()),
      );

      expect(failure.message, 'Server error');
    });
  });
}
