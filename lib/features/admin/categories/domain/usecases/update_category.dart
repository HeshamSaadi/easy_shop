import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class UpdateCategory {
  const UpdateCategory(this._repository);
  final CategoryRepository _repository;
  Future<void> call({
    required String slug,
    required String name,
    String? description,
  }) {
    return _repository.updateCategory(
      slug: slug,
      name: name,
      description: description,
    );
  }
}
