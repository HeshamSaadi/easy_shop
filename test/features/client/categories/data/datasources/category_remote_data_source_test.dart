import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/features/client/categories/data/datasources/category_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/fake_api_consumer.dart';

/// Records the paths the data source calls, and answers with [response].
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
  late CategoryRemoteDataSourceImpl dataSource;

  setUp(() {
    api = _RecordingApi();
    dataSource = CategoryRemoteDataSourceImpl(api);
  });

  test('gets the client categories endpoint and parses the list', () async {
    api.response = <String, dynamic>{
      'data': [
        {'id': 1, 'name': 'Audio', 'slug': 'audio', 'description': null},
        {'id': 2, 'name': 'Laptops', 'slug': 'laptops', 'description': 'PCs'},
      ],
      'message': 'Data retrieved successfully',
    };

    final categories = await dataSource.getCategories();

    expect(api.getPaths, [EndPoints.clientCategories]);
    expect(categories.map((c) => c.slug).toList(), ['audio', 'laptops']);
    expect(categories.last.description, 'PCs');
  });

  test('an empty list gives no categories', () async {
    api.response = <String, dynamic>{'data': [], 'message': 'ok'};

    final categories = await dataSource.getCategories();

    expect(categories, isEmpty);
  });
}
