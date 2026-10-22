import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  Future<Either<Failure, List<CategoryEntity>>> call() async {
    final result = await _repository.getCategories();
    return result.map(_sortByName);
  }

  List<CategoryEntity> _sortByName(List<CategoryEntity> categories) {
    return [...categories]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
