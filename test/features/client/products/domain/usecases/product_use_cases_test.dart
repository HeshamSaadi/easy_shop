import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../product_test_helpers.dart';

class _StubProductRepository implements ProductRepository {
  Either<Failure, List<ProductEntity>> listResult = const Right([]);
  Either<Failure, ProductEntity> detailsResult = const Left(Failure('none'));
  String? requestedSlug;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      listResult;

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(String slug) async {
    requestedSlug = slug;
    return detailsResult;
  }
}

void main() {
  late _StubProductRepository repository;

  setUp(() => repository = _StubProductRepository());

  group('GetProducts', () {
    test('removes hidden products', () async {
      repository.listResult = Right([
        buildProduct(id: 1),
        buildProduct(id: 2, isVisible: false),
        buildProduct(id: 3),
      ]);

      final result = await GetProducts(repository)();

      final ids = result.getOrElse(() => []).map((p) => p.id).toList();
      expect(ids, [1, 3]);
    });

    test('keeps a visible product that is out of stock', () async {
      repository.listResult = Right([buildProduct(stock: 0)]);

      final result = await GetProducts(repository)();

      expect(result.getOrElse(() => []), hasLength(1));
    });

    test('an empty list stays empty', () async {
      final result = await GetProducts(repository)();

      expect(result.getOrElse(() => [buildProduct()]), isEmpty);
    });

    test('passes a failure through', () async {
      repository.listResult = const Left(Failure('No internet'));

      final result = await GetProducts(repository)();

      result.fold(
        (failure) => expect(failure.message, 'No internet'),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('GetProductDetails', () {
    test('sends the slug and returns the product', () async {
      repository.detailsResult = Right(buildProduct(slug: 'samsung-a-24'));

      final result = await GetProductDetails(repository)('samsung-a-24');

      expect(repository.requestedSlug, 'samsung-a-24');
      expect(result.getOrElse(() => buildProduct()).slug, 'samsung-a-24');
    });

    test('passes a failure through', () async {
      repository.detailsResult = const Left(Failure('Product is not found'));

      final result = await GetProductDetails(repository)('x');

      result.fold(
        (failure) => expect(failure.message, 'Product is not found'),
        (_) => fail('expected a Failure'),
      );
    });
  });
}
