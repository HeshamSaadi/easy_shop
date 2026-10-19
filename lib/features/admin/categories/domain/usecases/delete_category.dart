import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class DeleteCategory {
  const DeleteCategory(this._repository);
  final CategoryRepository _repository;
  Future<void> call(String slug) => _repository.deleteCategory(slug);
}
