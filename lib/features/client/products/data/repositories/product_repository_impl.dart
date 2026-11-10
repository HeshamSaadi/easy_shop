import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/client/products/data/datasources/product_remote_data_source.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() {
    return guardedCall(_remote.getProducts);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(String slug) {
    return guardedCall(() => _remote.getProductDetails(slug));
  }
}
