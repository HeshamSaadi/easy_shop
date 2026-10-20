import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
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

  static const String _base = '/admin/categories';
  static const String _store = '$_base/store';
  static const String _update = '$_base/update';
  static const String _destroy = '$_base/destroy';

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _api.get(_base);
    final data = response is Map<String, dynamic> ? response['data'] : null;
    if (data is! List) throw const UnknownException();

    return data
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  @override
  Future<void> addCategory({required String name, String? description}) async {
    await _api.post(_store, data: _body(name, description));
  }

  @override
  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) async {
    await _api.put(
      '$_update/${Uri.encodeComponent(slug)}',
      data: _body(name, description),
    );
  }

  @override
  Future<void> deleteCategory(String slug) async {
    await _api.delete('$_destroy/${Uri.encodeComponent(slug)}');
  }

  Map<String, dynamic> _body(String name, String? description) {
    return {'name': name.trim(), 'description': description?.trim() ?? ''};
  }
}
