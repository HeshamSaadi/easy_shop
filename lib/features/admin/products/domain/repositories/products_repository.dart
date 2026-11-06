import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';

abstract class ProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();

  Future<Either<Failure, ProductEntity>> getProduct(String slug);

  Future<Either<Failure, ProductEntity>> createProduct(ProductParams params);

  Future<Either<Failure, ProductEntity>> updateProduct(
    String slug,
    ProductParams params,
  );

  Future<Either<Failure, Unit>> deleteProduct(String slug);
}
