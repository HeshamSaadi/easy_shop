import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class AddCategory {
  const AddCategory(this._repository);
  final CategoryRepository _repository;
  Future<void> call({required String name, String? description}) {
    return _repository.addCategory(name: name, description: description);
  }
}
