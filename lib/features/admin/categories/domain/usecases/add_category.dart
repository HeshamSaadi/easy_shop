import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class AddCategory {
  const AddCategory(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, Unit>> call({
    required String name,
    String? description,
  }) {
    return _repository.addCategory(name: name, description: description);
  }
}
