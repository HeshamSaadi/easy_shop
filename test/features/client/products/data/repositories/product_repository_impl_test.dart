import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/products/data/datasources/product_remote_data_source.dart';
import 'package:easy_shop/features/client/products/data/models/product_model.dart';
import 'package:easy_shop/features/client/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../product_test_helpers.dart';

class _FakeProductRemoteDataSource implements ProductRemoteDataSource {
  List<ProductModel> products = [];
  AppException? error;
  bool unexpectedError = false;
  String? requestedSlug;

  void _throwIfNeeded() {
    final appError = error;
    if (appError != null) throw appError;
    if (unexpectedError) throw StateError('unexpected');
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    _throwIfNeeded();
    return products;
  }

  @override
  Future<ProductModel> getProductDetails(String slug) async {
    _throwIfNeeded();
    requestedSlug = slug;
    return ProductModel.fromJson(clientProductJson(overrides: {'slug': slug}));
  }
}

void main() {
  late _FakeProductRemoteDataSource remote;
  late ProductRepositoryImpl repository;

  setUp(() {
    remote = _FakeProductRemoteDataSource();
    repository = ProductRepositoryImpl(remote);
  });

  group('getProducts', () {
    test('returns the products from the data source', () async {
      remote.products = [ProductModel.fromJson(clientProductJson())];

      final result = await repository.getProducts();

      expect(result.getOrElse(() => []).single.id, 32);
    });

    test('turns an AppException into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.getProducts();

      result.fold(
        (failure) => expect(failure.message, const ServerException().message),
        (_) => fail('expected a Failure'),
      );
    });

    test('turns an unexpected error into a Failure', () async {
      remote.unexpectedError = true;

      final result = await repository.getProducts();

      result.fold(
        (failure) => expect(failure.message, const UnknownException().message),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('getProductDetails', () {
    test('sends the slug to the data source', () async {
      final result = await repository.getProductDetails('samsung-a-24');

      expect(result.isRight(), isTrue);
      expect(remote.requestedSlug, 'samsung-a-24');
    });

    test('turns an exception into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.getProductDetails('x');

      expect(result.isLeft(), isTrue);
    });
  });
}
