import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/client/categories/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  const CategoryRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get(EndPoints.clientCategories);
    return ResponseReader.list(response).map(CategoryModel.fromJson).toList();
  }
}
