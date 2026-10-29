import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../home_test_helpers.dart';

void main() {
  late FakeGetCategories categories;
  late FakeGetProducts products;
  late FakeGetOrders orders;
  late GetDashboardStats useCase;

  setUp(() {
    categories = FakeGetCategories();
    products = FakeGetProducts();
    orders = FakeGetOrders();
    useCase = GetDashboardStats(
      getCategories: categories,
      getProducts: products,
      getOrders: orders,
    );
  });

  Future<DashboardStats> run() async {
    final result = await useCase();
    return result.getOrElse(() => throw StateError('expected a Right'));
  }

  test('counts categories, products and orders', () async {
    categories.result = Right([buildCategory('a'), buildCategory('b')]);
    products.result = Right([buildProduct('p1')]);
    orders.result = Right([buildOrder(code: 'o1'), buildOrder(code: 'o2')]);

    final stats = await run();

    expect(stats.categoriesCount, 2);
    expect(stats.productsCount, 1);
    expect(stats.ordersCount, 2);
  });

  test('counts only pending orders, ignoring case and spaces', () async {
    orders.result = Right([
      buildOrder(code: 'a', status: 'pending'),
      buildOrder(code: 'b', status: ' Pending '),
      buildOrder(code: 'c', status: 'delivered'),
    ]);

    final stats = await run();

    expect(stats.pendingOrdersCount, 2);
  });

  test(
    'recent orders are newest first and limited to the preview size',
    () async {
      orders.result = Right([
        buildOrder(code: 'oct1', createdAt: DateTime.utc(2026, 10, 1)),
        buildOrder(code: 'oct3', createdAt: DateTime.utc(2026, 10, 3)),
        buildOrder(code: 'oct2', createdAt: DateTime.utc(2026, 10, 2)),
        buildOrder(code: 'oct5', createdAt: DateTime.utc(2026, 10, 5)),
      ]);

      final stats = await run();

      expect(stats.recentOrders.map((o) => o.code), ['oct5', 'oct3', 'oct2']);
    },
  );

  test('an order without a date goes last', () async {
    orders.result = Right([
      buildOrder(code: 'no-date'),
      buildOrder(code: 'dated', createdAt: DateTime.utc(2026, 10, 1)),
    ]);

    final stats = await run();

    expect(stats.recentOrders.map((o) => o.code), ['dated', 'no-date']);
  });

  test(
    'overview shows the first products, limited to the preview size',
    () async {
      products.result = Right([
        buildProduct('p1'),
        buildProduct('p2'),
        buildProduct('p3'),
        buildProduct('p4'),
      ]);

      final stats = await run();

      expect(stats.overviewProducts.map((p) => p.name), ['p1', 'p2', 'p3']);
    },
  );

  test('does not change the order of the original lists', () async {
    final original = [
      buildOrder(code: 'old', createdAt: DateTime.utc(2026, 10, 1)),
      buildOrder(code: 'new', createdAt: DateTime.utc(2026, 10, 5)),
    ];
    orders.result = Right(original);

    await run();

    expect(original.map((o) => o.code), ['old', 'new']);
  });

  group('returns the failure when one list fails', () {
    const failure = Failure('Server error');

    test('categories', () async {
      categories.result = const Left(failure);
      final result = await useCase();
      expect(result, const Left<Failure, DashboardStats>(failure));
    });

    test('products', () async {
      products.result = const Left(failure);
      final result = await useCase();
      expect(result, const Left<Failure, DashboardStats>(failure));
    });

    test('orders', () async {
      orders.result = const Left(failure);
      final result = await useCase();
      expect(result, const Left<Failure, DashboardStats>(failure));
    });
  });
}
