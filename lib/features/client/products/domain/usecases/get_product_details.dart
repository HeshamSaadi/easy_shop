import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';

class GetProductDetails {
  const GetProductDetails(this._repository);

  final ProductRepository _repository;

  Future<Either<Failure, ProductEntity>> call(String slug) {
    return _repository.getProductDetails(slug);
  }
}
