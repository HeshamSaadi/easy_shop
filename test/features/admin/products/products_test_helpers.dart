import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';

/// Hand-written fake. Set a result before the call and read what the
/// repository received afterwards.
class FakeProductsRepository implements ProductsRepository {
  Either<Failure, List<ProductEntity>> productsResult = const Right([]);
  Either<Failure, ProductEntity> productResult = Right(buildProduct());
  Either<Failure, Unit> deleteResult = const Right(unit);

  /// The slug the last get, update or delete call received.
  String? requestedSlug;

  /// The params the last create or update call received.
  ProductParams? receivedParams;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    return productsResult;
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(String slug) async {
    requestedSlug = slug;
    return productResult;
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductParams params,
  ) async {
    receivedParams = params;
    return productResult;
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    String slug,
    ProductParams params,
  ) async {
    requestedSlug = slug;
    receivedParams = params;
    return productResult;
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String slug) async {
    requestedSlug = slug;
    return deleteResult;
  }
}

ProductEntity buildProduct({
  String slug = 'smart-watch',
  String name = 'Smart Watch',
  ProductCategoryEntity? category,
}) {
  return ProductEntity(
    id: 9,
    name: name,
    slug: slug,
    price: 150,
    quantity: 10,
    categoryId: 2,
    isVisible: true,
    imageUrl: 'https://example.com/watch.png',
    category: category,
  );
}

ProductParams buildParams() {
  return const ProductParams(
    name: 'Smart Watch',
    price: 150,
    quantity: 10,
    categoryId: 2,
    isVisible: true,
  );
}
