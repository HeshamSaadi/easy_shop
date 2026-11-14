import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/orders/data/datasources/orders_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';
import '../../client_orders_test_helpers.dart';

/// Records the calls the orders feature makes, and answers with [response].
class _RecordingOrdersApi extends FakeApiConsumer {
  dynamic response;

  final List<String> getPaths = [];
  final List<({String path, Object? data})> postCalls = [];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    getPaths.add(path);
    return response;
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    postCalls.add((path: path, data: data));
    return response;
  }
}

void main() {
  late _RecordingOrdersApi api;
  late OrdersRemoteDataSourceImpl dataSource;

  setUp(() {
    api = _RecordingOrdersApi();
    dataSource = OrdersRemoteDataSourceImpl(api);
  });

  group('getOrders', () {
    test('gets the orders endpoint and parses the list', () async {
      api.response = <String, dynamic>{
        'data': [clientOrderJson(), clientOrderJson()],
        'message': 'Data retrieved successfully',
      };

      final orders = await dataSource.getOrders();

      expect(api.getPaths, [EndPoints.clientOrders]);
      expect(orders, hasLength(2));
      expect(orders.first.items, hasLength(2));
    });

    test('throws a ServerException when data is not a list', () async {
      api.response = <String, dynamic>{'data': null, 'message': 'ok'};

      await expectLater(
        dataSource.getOrders(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOrder', () {
    test('gets the details path for that code', () async {
      api.response = <String, dynamic>{
        'data': clientOrderJson(),
        'message': 'Data retrieved successfully',
      };

      final order = await dataSource.getOrder('66D1BJIY');

      expect(api.getPaths, [EndPoints.clientOrderDetails('66D1BJIY')]);
      expect(api.getPaths.single, '/client/orders/show/66D1BJIY');
      expect(order.code, '66D1BJIY');
    });

    test('encodes special characters in the code', () async {
      api.response = <String, dynamic>{
        'data': clientOrderJson(),
        'message': 'ok',
      };

      await dataSource.getOrder('A B');

      expect(api.getPaths.single, '/client/orders/show/A%20B');
    });

    test('throws a ServerException when data is not an object', () async {
      api.response = <String, dynamic>{'data': <dynamic>[], 'message': 'ok'};

      await expectLater(
        dataSource.getOrder('66D1BJIY'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('placeOrder', () {
    test('posts the exact body to the store endpoint', () async {
      api.response = <String, dynamic>{
        'data': clientOrderJson(),
        'message': 'Order has been created successfully',
      };

      final order = await dataSource.placeOrder(buildPlaceOrderParams());

      expect(api.postCalls.single.path, EndPoints.clientOrderStore);
      expect(api.postCalls.single.data, {
        'product_id': [32, 33],
        'quantity': [2, 1],
        'price': [220.0, 600.0],
        'address': 'Cairo, Egypt',
        'latitude': 30.033333,
        'longitude': 31.233334,
        'payment_method': 'cash',
      });
      expect(order.code, '66D1BJIY');
    });

    test('throws a ServerException when the response has no order', () async {
      api.response = <String, dynamic>{'data': null, 'message': 'ok'};

      await expectLater(
        dataSource.placeOrder(buildPlaceOrderParams()),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
