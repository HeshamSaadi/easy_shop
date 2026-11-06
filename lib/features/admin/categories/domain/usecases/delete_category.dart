import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class DeleteCategory {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, Unit>> call(String slug) {
    return _repository.deleteCategory(slug);
  }
}
