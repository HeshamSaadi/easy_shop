import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class UpdateProduct {
  const UpdateProduct(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductEntity>> call({
    required String slug,
    required ProductParams params,
  }) {
    return _repository.updateProduct(slug, params);
  }
}
