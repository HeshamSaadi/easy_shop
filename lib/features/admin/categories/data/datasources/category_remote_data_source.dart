import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/admin/categories/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<void> addCategory({required String name, String? description});

  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  });

  Future<void> deleteCategory(String slug);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  const CategoryRemoteDataSourceImpl(this._api);

  final ApiConsumer _api;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get(EndPoints.adminCategories);
    return ResponseReader.list(response).map(CategoryModel.fromJson).toList();
  }

  @override
  Future<void> addCategory({required String name, String? description}) async {
    await _api.post(
      EndPoints.adminCategoryStore,
      data: _body(name, description),
    );
  }

  @override
  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) async {
    // JSON body, so a plain PUT works (only FormData needs POST + _method).
    await _api.put(
      EndPoints.adminCategoryUpdate(slug),
      data: _body(name, description),
    );
  }

  @override
  Future<void> deleteCategory(String slug) async {
    await _api.delete(EndPoints.adminCategoryDelete(slug));
  }

  // An empty description is saved as null by the server.
  Map<String, dynamic> _body(String name, String? description) {
    return {'name': name.trim(), 'description': description?.trim() ?? ''};
  }
}
