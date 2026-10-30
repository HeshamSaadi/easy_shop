import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products_test_helpers.dart';

void main() {
  late FakeProductsRepository repository;
  late ProductsCubit cubit;

  setUp(() {
    repository = FakeProductsRepository();
    cubit = ProductsCubit(getProducts: GetProducts(repository));
  });

  tearDown(() => cubit.close());

  /// A watch and a T-shirt, so the search has something to tell apart.
  List<dynamic> twoProducts() {
    return [
      buildProduct(),
      buildProduct(
        name: 'Cotton T-Shirt',
        slug: 'cotton-t-shirt',
        category: const ProductCategoryEntity(
          id: 3,
          name: 'Clothing',
          slug: 'clothing',
        ),
      ),
    ];
  }

  group('load', () {
    test('starts in ProductsInitial', () {
      expect(cubit.state, isA<ProductsInitial>());
    });

    test('emits Loading then Loaded with the products', () async {
      repository.productsResult = Right([buildProduct(), buildProduct()]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductsLoading>(),
          isA<ProductsLoaded>().having((s) => s.products.length, 'count', 2),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('with no products emits Loaded with an empty list', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductsLoading>(),
          isA<ProductsLoaded>().having((s) => s.products, 'products', isEmpty),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('emits Loading then Error with the failure message', () async {
      repository.productsResult = const Left(Failure('No internet'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductsLoading>(),
          isA<ProductsError>().having(
            (s) => s.message,
            'message',
            'No internet',
          ),
        ]),
      );

      await cubit.load();
      await expectation;
    });
  });

  group('refresh', () {
    test('replaces the products without showing Loading', () async {
      await cubit.load();
      repository.productsResult = Right([buildProduct(slug: 'new-one')]);

      final expectation = expectLater(
        cubit.stream,
        emits(
          isA<ProductsLoaded>()
              .having((s) => s.products.single.slug, 'slug', 'new-one')
              .having((s) => s.actionError, 'actionError', isNull),
        ),
      );

      await cubit.refresh();
      await expectation;
    });

    test('keeps the search text', () async {
      repository.productsResult = Right(twoProducts().cast());
      await cubit.load();
      cubit.search('watch');

      final expectation = expectLater(
        cubit.stream,
        emits(isA<ProductsLoaded>().having((s) => s.query, 'query', 'watch')),
      );

      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh keeps the list and the search text', () async {
      repository.productsResult = Right(twoProducts().cast());
      await cubit.load();
      cubit.search('watch');
      repository.productsResult = const Left(Failure('Server error'));

      final expectation = expectLater(
        cubit.stream,
        emits(
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'count', 2)
              .having((s) => s.query, 'query', 'watch')
              .having((s) => s.actionError, 'actionError', 'Server error'),
        ),
      );

      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh before anything was loaded emits Error', () async {
      repository.productsResult = const Left(Failure('Server error'));

      final expectation = expectLater(
        cubit.stream,
        emits(isA<ProductsError>()),
      );

      await cubit.refresh();
      await expectation;
    });
  });

  group('search', () {
    setUp(() async {
      repository.productsResult = Right(twoProducts().cast());
      await cubit.load();
    });

    List<String> visibleNames() {
      final state = cubit.state;
      if (state is! ProductsLoaded) return [];
      return state.visibleProducts.map((product) => product.name).toList();
    }

    test('matches the product name, ignoring case', () {
      cubit.search('WATCH');

      expect(visibleNames(), ['Smart Watch']);
    });

    test('matches the category name', () {
      cubit.search('cloth');

      expect(visibleNames(), ['Cotton T-Shirt']);
    });

    test('shows nothing when no product matches', () {
      cubit.search('xyz');

      expect(visibleNames(), isEmpty);
    });
  });

  test('search before the products are loaded does nothing', () {
    cubit.search('watch');

    expect(cubit.state, isA<ProductsInitial>());
  });
}
