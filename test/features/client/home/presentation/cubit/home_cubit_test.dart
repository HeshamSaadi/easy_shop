import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_state.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubCategoryRepository implements CategoryRepository {
  Either<Failure, List<CategoryEntity>> result = const Right([]);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async => result;
}

class _StubProductRepository implements ProductRepository {
  Either<Failure, List<ProductEntity>> listResult = const Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async =>
      listResult;

  @override
  Future<Either<Failure, ProductEntity>> getProductDetails(String slug) async =>
      const Left(Failure('unused'));
}

CategoryEntity _category(int id, String name) =>
    CategoryEntity(id: id, name: name, slug: 'slug-$id');

ProductEntity _product(
  int id,
  String name, {
  int categoryId = 1,
  String categoryName = 'Mobile Phone',
  bool isVisible = true,
}) {
  return ProductEntity(
    id: id,
    name: name,
    slug: 'product-$id',
    price: 100,
    stock: 10,
    categoryId: categoryId,
    categoryName: categoryName,
    isVisible: isVisible,
    imageUrl: 'https://example.com/$id.png',
    storeName: 'Store',
  );
}

List<String> _names(HomeState state) =>
    (state as HomeLoaded).visibleProducts.map((p) => p.name).toList();

void main() {
  late _StubCategoryRepository categories;
  late _StubProductRepository products;
  late HomeCubit cubit;

  setUp(() {
    categories = _StubCategoryRepository()
      ..result = Right([_category(2, 'Laptops'), _category(1, 'audio')]);
    products = _StubProductRepository()
      ..listResult = Right([
        _product(1, 'Samsung A24'),
        _product(2, 'iPhone 14'),
        _product(3, 'Dell XPS', categoryId: 2, categoryName: 'Laptops'),
        _product(4, 'Hidden Phone', isVisible: false),
      ]);
    cubit = HomeCubit(
      getCategories: GetCategories(categories),
      getProducts: GetProducts(products),
    );
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('emits Loading, then Loaded with sorted categories and visible '
        'products', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeLoaded>()
              .having(
                (s) => s.categories.map((c) => c.name).toList(),
                'categories',
                ['audio', 'Laptops'],
              )
              .having((s) => s.products.length, 'products', 3),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('a categories failure emits Error', () async {
      categories.result = const Left(Failure('No internet'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeError>().having((s) => s.message, 'message', 'No internet'),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('a products failure emits Error', () async {
      products.listResult = const Left(Failure('Server error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeError>().having((s) => s.message, 'message', 'Server error'),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('does not emit Loaded after the Cubit is closed', () async {
      final states = <HomeState>[];
      final subscription = cubit.stream.listen(states.add);

      final loading = cubit.load();
      await cubit.close();
      await loading;
      await subscription.cancel();

      expect(states.whereType<HomeLoaded>(), isEmpty);
    });
  });

  group('selectCategory and search', () {
    setUp(() async => cubit.load());

    test('selectCategory shows only that category', () {
      cubit.selectCategory(2);

      expect(_names(cubit.state), ['Dell XPS']);
    });

    test('selectCategory(null) shows everything again', () {
      cubit.selectCategory(2);
      cubit.selectCategory(null);

      expect(_names(cubit.state), ['Samsung A24', 'iPhone 14', 'Dell XPS']);
    });

    test('search matches the product name, ignoring case', () {
      cubit.search('IPHONE');

      expect(_names(cubit.state), ['iPhone 14']);
    });

    test('search also matches the category name', () {
      cubit.search('laptop');

      expect(_names(cubit.state), ['Dell XPS']);
    });

    test('a blank query shows everything', () {
      cubit.search('   ');

      expect(_names(cubit.state), hasLength(3));
    });

    test('category and search work together', () {
      cubit.selectCategory(1);
      cubit.search('iphone');

      expect(_names(cubit.state), ['iPhone 14']);
    });

    test('both are ignored before the list is loaded', () {
      final fresh = HomeCubit(
        getCategories: GetCategories(categories),
        getProducts: GetProducts(products),
      );
      addTearDown(fresh.close);

      fresh.selectCategory(1);
      fresh.search('x');

      expect(fresh.state, isA<HomeInitial>());
    });
  });

  group('refresh', () {
    setUp(() async => cubit.load());

    test('does not emit Loading and keeps the category and query', () async {
      cubit.selectCategory(1);
      cubit.search('iphone');
      products.listResult = Right([
        _product(2, 'iPhone 14'),
        _product(5, 'iPhone 15'),
      ]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeLoaded>()
              .having((s) => s.selectedCategoryId, 'category', 1)
              .having((s) => s.query, 'query', 'iphone')
              .having((s) => s.products.length, 'products', 2),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('resets a selected category that no longer exists', () async {
      cubit.selectCategory(2);
      categories.result = Right([_category(1, 'audio')]);

      await cubit.refresh();

      expect((cubit.state as HomeLoaded).selectedCategoryId, isNull);
    });

    test('a failed refresh keeps the data and sets refreshError', () async {
      products.listResult = const Left(Failure('Server error'));

      await cubit.refresh();

      final state = cubit.state as HomeLoaded;
      expect(state.products, hasLength(3));
      expect(state.refreshError, 'Server error');
    });

    test('a successful refresh clears an earlier refreshError', () async {
      products.listResult = const Left(Failure('Server error'));
      await cubit.refresh();

      products.listResult = Right([_product(1, 'Samsung A24')]);
      await cubit.refresh();

      expect((cubit.state as HomeLoaded).refreshError, isNull);
    });
  });

  test('a failed refresh with no data yet emits Error', () async {
    products.listResult = const Left(Failure('Server error'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<HomeError>()]),
    );
    await cubit.refresh();
    await expectation;
  });
}
