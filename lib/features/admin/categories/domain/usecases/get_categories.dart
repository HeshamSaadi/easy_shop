import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);
  final CategoryRepository _repository;
  Future<List<CategoryEntity>> call() => _repository.getCategories();
}
