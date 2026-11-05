import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

/// Hand-written fake: set the result you want, then check [calls].
class FakeCategoryRepository implements CategoryRepository {
  Either<Failure, List<CategoryEntity>> getResult =
      const Right<Failure, List<CategoryEntity>>(<CategoryEntity>[]);
  Either<Failure, Unit> actionResult = const Right<Failure, Unit>(unit);

  final List<String> calls = [];

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    calls.add('get');
    return getResult;
  }

  @override
  Future<Either<Failure, Unit>> addCategory({
    required String name,
    String? description,
  }) async {
    calls.add('add:$name:${description ?? ''}');
    return actionResult;
  }

  @override
  Future<Either<Failure, Unit>> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) async {
    calls.add('update:$slug:$name:${description ?? ''}');
    return actionResult;
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String slug) async {
    calls.add('delete:$slug');
    return actionResult;
  }
}
