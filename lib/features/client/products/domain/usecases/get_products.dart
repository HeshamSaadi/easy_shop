import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  /// The API also returns hidden products, so they are removed here.
  Future<Either<Failure, List<ProductEntity>>> call() async {
    final result = await _repository.getProducts();
    return result.map(
      (products) => products.where((product) => product.isVisible).toList(),
    );
  }
}
