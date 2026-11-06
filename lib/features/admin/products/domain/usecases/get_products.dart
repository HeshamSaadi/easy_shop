import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call() {
    return _repository.getProducts();
  }
}
