import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, Unit>> addCategory({
    required String name,
    String? description,
  });

  Future<Either<Failure, Unit>> updateCategory({
    required String slug,
    required String name,
    String? description,
  });

  Future<Either<Failure, Unit>> deleteCategory(String slug);
}
