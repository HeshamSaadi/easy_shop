import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/cart/data/datasources/cart_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';
import '../../cart_test_helpers.dart';

/// Records the calls the cart makes, and answers with [response].
class _RecordingCartApi extends FakeApiConsumer {
  dynamic response;

  final List<String> getPaths = [];
  final List<({String path, Object? data})> postCalls = [];
  final List<({String path, Object? data})> deleteCalls = [];

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

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    deleteCalls.add((path: path, data: data));
    return response;
  }
}

void main() {
  late _RecordingCartApi api;
  late CartRemoteDataSourceImpl dataSource;

  setUp(() {
    api = _RecordingCartApi();
    dataSource = CartRemoteDataSourceImpl(api);
  });

  group('getCart', () {
    test('gets the cart endpoint and parses the items', () async {
      api.response = <String, dynamic>{
        'data': [cartItemJson(quantity: 2), cartItemJson(quantity: 5)],
        'message': 'Data retrieved successfully',
      };

      final items = await dataSource.getCart();

      expect(api.getPaths, [EndPoints.clientCart]);
      expect(items.map((item) => item.quantity), [2, 5]);
      expect(items.first.product.storeName, 'Elbatal Store');
    });

    test('an empty cart is an empty list', () async {
      api.response = <String, dynamic>{'data': <dynamic>[], 'message': 'ok'};

      expect(await dataSource.getCart(), isEmpty);
    });

    test('throws a ServerException when data is not a list', () async {
      api.response = <String, dynamic>{'data': null, 'message': 'ok'};

      await expectLater(dataSource.getCart(), throwsA(isA<ServerException>()));
    });
  });

  group('setQuantity', () {
    test('posts product_id and quantity to the store endpoint', () async {
      api.response = <String, dynamic>{
        'data': null,
        'message': 'Product added successfully',
      };

      await dataSource.setQuantity(productId: 32, quantity: 5);

      expect(api.postCalls.single.path, EndPoints.clientCartStore);
      expect(api.postCalls.single.data, {'product_id': 32, 'quantity': 5});
    });
  });

  group('removeFromCart', () {
    test('sends product_id as the body of a DELETE', () async {
      api.response = <String, dynamic>{
        'data': null,
        'message': 'Product deleted successfully',
      };

      await dataSource.removeFromCart(32);

      expect(api.deleteCalls.single.path, EndPoints.clientCartDestroy);
      expect(api.deleteCalls.single.data, {'product_id': 32});
    });
  });
}
