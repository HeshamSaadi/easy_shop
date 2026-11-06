import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/admin/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return guardedCall(_remote.getCategories);
  }

  @override
  Future<Either<Failure, Unit>> addCategory({
    required String name,
    String? description,
  }) {
    return guardedCall(() async {
      await _remote.addCategory(name: name, description: description);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) {
    return guardedCall(() async {
      await _remote.updateCategory(
        slug: slug,
        name: name,
        description: description,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String slug) {
    return guardedCall(() async {
      await _remote.deleteCategory(slug);
      return unit;
    });
  }
}
