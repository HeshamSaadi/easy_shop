import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/products/data/datasources/products_remote_data_source.dart';
import 'package:easy_shop/features/admin/products/data/models/product_model.dart';
import 'package:easy_shop/features/admin/products/data/repositories/products_repository_impl.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../product_json_fixture.dart';
import '../../products_test_helpers.dart';

/// Hand-written fake, like the orders tests. Throws [error] when it is set.
class _FakeProductsRemoteDataSource implements ProductsRemoteDataSource {
  _FakeProductsRemoteDataSource({this.products = const [], this.error});

  final List<ProductModel> products;
  final Object? error;

  String? requestedSlug;
  ProductParams? receivedParams;

  void _throwIfNeeded() {
    final failure = error;
    if (failure != null) throw failure;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    _throwIfNeeded();
    return products;
  }

  @override
  Future<ProductModel> getProduct(String slug) async {
    _throwIfNeeded();
    requestedSlug = slug;
    return products.firstWhere((product) => product.slug == slug);
  }

  @override
  Future<ProductModel> createProduct(ProductParams params) async {
    _throwIfNeeded();
    receivedParams = params;
    return products.first;
  }

  @override
  Future<ProductModel> updateProduct(String slug, ProductParams params) async {
    _throwIfNeeded();
    requestedSlug = slug;
    receivedParams = params;
    return products.first;
  }

  @override
  Future<void> deleteProduct(String slug) async {
    _throwIfNeeded();
    requestedSlug = slug;
  }
}

void main() {
  final product = ProductModel.fromJson(productJson());

  test('getProducts returns the products on success', () async {
    final repository = ProductsRepositoryImpl(
      _FakeProductsRemoteDataSource(products: [product]),
    );

    final result = await repository.getProducts();

    result.fold(
      (_) => fail('Expected Right'),
      (products) => expect(products.single.slug, 'smart-watch'),
    );
  });

  test('getProduct returns the product with that slug', () async {
    final dataSource = _FakeProductsRemoteDataSource(products: [product]);
    final repository = ProductsRepositoryImpl(dataSource);

    final result = await repository.getProduct('smart-watch');

    expect(dataSource.requestedSlug, 'smart-watch');
    result.fold(
      (_) => fail('Expected Right'),
      (found) => expect(found.name, 'Smart Watch'),
    );
  });

  test('createProduct sends the params and returns the product', () async {
    final dataSource = _FakeProductsRemoteDataSource(products: [product]);
    final repository = ProductsRepositoryImpl(dataSource);
    final params = buildParams();

    final result = await repository.createProduct(params);

    expect(dataSource.receivedParams, same(params));
    expect(result.isRight(), isTrue);
  });

  test('updateProduct sends the slug and the params', () async {
    final dataSource = _FakeProductsRemoteDataSource(products: [product]);
    final repository = ProductsRepositoryImpl(dataSource);
    final params = buildParams();

    final result = await repository.updateProduct('smart-watch', params);

    expect(dataSource.requestedSlug, 'smart-watch');
    expect(dataSource.receivedParams, same(params));
    expect(result.isRight(), isTrue);
  });

  test('deleteProduct sends the slug and returns unit', () async {
    final dataSource = _FakeProductsRemoteDataSource(products: [product]);
    final repository = ProductsRepositoryImpl(dataSource);

    final result = await repository.deleteProduct('smart-watch');

    expect(dataSource.requestedSlug, 'smart-watch');
    expect(result, const Right<dynamic, Unit>(unit));
  });

  test('an app exception becomes a Failure', () async {
    final repository = ProductsRepositoryImpl(
      _FakeProductsRemoteDataSource(error: const ServerException()),
    );

    final result = await repository.getProducts();

    expect(result.isLeft(), isTrue);
  });

  test('an unexpected error becomes a Failure and does not crash', () async {
    final repository = ProductsRepositoryImpl(
      _FakeProductsRemoteDataSource(error: StateError('boom')),
    );

    final result = await repository.deleteProduct('smart-watch');

    expect(result.isLeft(), isTrue);
  });
}
