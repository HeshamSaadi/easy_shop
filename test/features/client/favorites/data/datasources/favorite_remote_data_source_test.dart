import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/client/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';
import '../../../products/product_test_helpers.dart';

class _RecordingApi extends FakeApiConsumer {
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

/// A favorite as the server returns it: the row, with the full product.
Map<String, dynamic> _favoriteJson({Map<String, dynamic>? product}) {
  return <String, dynamic>{
    'id': 1,
    'client_id': 4,
    'product_id': 32,
    'product': ?product,
  };
}

void main() {
  late _RecordingApi api;
  late FavoriteRemoteDataSourceImpl dataSource;

  setUp(() {
    api = _RecordingApi();
    dataSource = FavoriteRemoteDataSourceImpl(api);
  });

  group('getFavorites', () {
    test('gets the favorites endpoint and reads the nested product', () async {
      api.response = <String, dynamic>{
        'data': [_favoriteJson(product: clientProductJson())],
        'message': 'Data retrieved successfully',
      };

      final products = await dataSource.getFavorites();

      expect(api.getPaths, [EndPoints.clientFavorites]);
      expect(products.single.slug, 'samsung-a-24');
      expect(products.single.storeName, 'Elbatal Store');
    });

    test('skips an item that has no product', () async {
      api.response = <String, dynamic>{
        'data': [_favoriteJson(), _favoriteJson(product: clientProductJson())],
        'message': 'ok',
      };

      final products = await dataSource.getFavorites();

      expect(products, hasLength(1));
    });

    test('an empty list gives no favorites', () async {
      api.response = <String, dynamic>{'data': [], 'message': 'ok'};

      expect(await dataSource.getFavorites(), isEmpty);
    });
  });

  test('addFavorite posts the product id in the JSON body', () async {
    api.response = <String, dynamic>{'data': null, 'message': 'ok'};

    await dataSource.addFavorite(32);

    expect(api.postCalls.single.path, EndPoints.clientFavoriteStore);
    expect(api.postCalls.single.data, {'product_id': 32});
  });

  test('removeFavorite sends DELETE with the product id in the body', () async {
    api.response = <String, dynamic>{'data': null, 'message': 'ok'};

    await dataSource.removeFavorite(32);

    expect(api.deleteCalls.single.path, EndPoints.clientFavoriteDestroy);
    expect(api.deleteCalls.single.data, {'product_id': 32});
  });
}
