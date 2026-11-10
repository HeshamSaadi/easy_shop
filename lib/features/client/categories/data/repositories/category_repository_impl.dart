import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/client/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remote);

  final CategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() {
    return guardedCall(_remote.getCategories);
  }
}
