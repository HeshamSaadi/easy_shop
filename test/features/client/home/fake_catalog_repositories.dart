import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';

/// Hand-written fake: returns the categories it was given and never uses
/// the network.
class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository({this.categories = const []});

  final List<CategoryEntity> categories;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    return Right(categories);
  }
}

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.products = const []});

  final List<ProductEntity> products;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    return Right(products);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(String slug) async {
    final matches = products.where((product) => product.slug == slug);
    if (matches.isEmpty) return const Left(Failure('Product not found'));
    return Right(matches.first);
  }
}
