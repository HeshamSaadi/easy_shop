import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class GetProductDetails {
  const GetProductDetails(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, ProductEntity>> call(String slug) {
    return _repository.getProduct(slug);
  }
}
