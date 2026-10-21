import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class DeleteProduct {
  const DeleteProduct(this._repository);

  final ProductsRepository _repository;

  Future<Either<Failure, Unit>> call(String slug) {
    return _repository.deleteProduct(slug);
  }
}
