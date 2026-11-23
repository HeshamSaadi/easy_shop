import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/client/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';
import '../../product_test_helpers.dart';

class _RecordingApi extends FakeApiConsumer {
  dynamic response;
  final List<String> getPaths = [];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    getPaths.add(path);
    return response;
  }
}

void main() {
  late _RecordingApi api;
  late ProductRemoteDataSourceImpl dataSource;

  setUp(() {
    api = _RecordingApi();
    dataSource = ProductRemoteDataSourceImpl(api);
  });

  group('getProducts', () {
    test('gets the products endpoint and parses the list', () async {
      api.response = <String, dynamic>{
        'data': [
          clientProductJson(),
          clientProductJson(overrides: {'id': 33, 'slug': 'iphone-14'}),
        ],
        'message': 'Data retrieved successfully',
      };

      final products = await dataSource.getProducts();

      expect(api.getPaths, [EndPoints.clientProducts]);
      expect(products.map((p) => p.slug).toList(), [
        'samsung-a-24',
        'iphone-14',
      ]);
    });

    test('an empty list gives no products', () async {
      api.response = <String, dynamic>{'data': [], 'message': 'ok'};

      expect(await dataSource.getProducts(), isEmpty);
    });
  });

  group('getProductDetails', () {
    test('gets the details path for the slug and parses one product', () async {
      api.response = <String, dynamic>{
        'data': clientProductJson(),
        'message': 'Data retrieved successfully',
      };

      final product = await dataSource.getProductDetails('samsung-a-24');

      expect(api.getPaths, [EndPoints.clientProductDetails('samsung-a-24')]);
      expect(product.name, 'Samsung A24');
    });
  });
}
