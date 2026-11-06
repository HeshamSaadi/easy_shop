import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/create_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/delete_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/update_product.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products_test_helpers.dart';

void main() {
  const failure = Failure('No internet connection');

  late FakeProductsRepository repository;

  setUp(() => repository = FakeProductsRepository());

  group('GetProducts', () {
    test('returns the products from the repository', () async {
      repository.productsResult = Right([
        buildProduct(),
        buildProduct(slug: 'other'),
      ]);

      final result = await GetProducts(repository)();

      result.fold(
        (_) => fail('Expected Right'),
        (products) => expect(products, hasLength(2)),
      );
    });

    test('returns the failure from the repository', () async {
      repository.productsResult = const Left(failure);

      final result = await GetProducts(repository)();

      result.fold(
        (found) => expect(found.message, failure.message),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('GetProductDetails', () {
    test('asks for the given slug and returns the product', () async {
      final result = await GetProductDetails(repository)('smart-watch');

      expect(repository.requestedSlug, 'smart-watch');
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository', () async {
      repository.productResult = const Left(failure);

      final result = await GetProductDetails(repository)('smart-watch');

      expect(result.isLeft(), isTrue);
    });
  });

  group('CreateProduct', () {
    test('passes the params and returns the product', () async {
      final params = buildParams();

      final result = await CreateProduct(repository)(params);

      expect(repository.receivedParams, same(params));
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository', () async {
      repository.productResult = const Left(failure);

      final result = await CreateProduct(repository)(buildParams());

      expect(result.isLeft(), isTrue);
    });
  });

  group('UpdateProduct', () {
    test('passes the slug and the params', () async {
      final params = buildParams();

      final result = await UpdateProduct(repository)(
        slug: 'smart-watch',
        params: params,
      );

      expect(repository.requestedSlug, 'smart-watch');
      expect(repository.receivedParams, same(params));
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository', () async {
      repository.productResult = const Left(failure);

      final result = await UpdateProduct(repository)(
        slug: 'smart-watch',
        params: buildParams(),
      );

      expect(result.isLeft(), isTrue);
    });
  });

  group('DeleteProduct', () {
    test('asks to delete the given slug', () async {
      final result = await DeleteProduct(repository)('smart-watch');

      expect(repository.requestedSlug, 'smart-watch');
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository', () async {
      repository.deleteResult = const Left(failure);

      final result = await DeleteProduct(repository)('smart-watch');

      expect(result.isLeft(), isTrue);
    });
  });
}
