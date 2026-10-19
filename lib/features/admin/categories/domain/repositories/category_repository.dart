import 'package:easy_shop/features/admin/categories/domain/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory({required String name, String? description});
  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  });
  Future<void> deleteCategory(String slug);
}
