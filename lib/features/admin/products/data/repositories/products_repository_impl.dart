import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/data/datasources/products_remote_data_source.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  const ProductsRepositoryImpl(this._remote);

  final ProductsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() {
    return _guard(_remote.getProducts);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String slug) {
    return _guard(() => _remote.getProduct(slug));
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductParams params) {
    return _guard(() => _remote.createProduct(params));
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    String slug,
    ProductParams params,
  ) {
    return _guard(() => _remote.updateProduct(slug, params));
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String slug) {
    return _guard(() async {
      await _remote.deleteProduct(slug);
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AppException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      return Left(Failure.fromException(const UnknownException()));
    }
  }
}
