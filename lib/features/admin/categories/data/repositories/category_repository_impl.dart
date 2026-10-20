import 'package:easy_shop/features/admin/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

/// No try/catch here on purpose: `DioConsumer` already turns every Dio error
/// into an `AppException`, and the cubit shows its message.
class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  @override
  Future<List<CategoryEntity>> getCategories() => _remote.getCategories();

  @override
  Future<void> addCategory({required String name, String? description}) {
    return _remote.addCategory(name: name, description: description);
  }

  @override
  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) {
    return _remote.updateCategory(
      slug: slug,
      name: name,
      description: description,
    );
  }

  @override
  Future<void> deleteCategory(String slug) => _remote.deleteCategory(slug);
}
