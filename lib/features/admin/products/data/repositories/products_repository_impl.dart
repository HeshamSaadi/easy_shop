import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/admin/products/data/datasources/products_remote_data_source.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() {
    return guardedCall(_remote.getProducts);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String slug) {
    return guardedCall(() => _remote.getProduct(slug));
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductParams params) {
    return guardedCall(() => _remote.createProduct(params));
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    String slug,
    ProductParams params,
  ) {
    return guardedCall(() => _remote.updateProduct(slug, params));
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String slug) {
    return guardedCall(() async {
      await _remote.deleteProduct(slug);
      return unit;
    });
  }
}
