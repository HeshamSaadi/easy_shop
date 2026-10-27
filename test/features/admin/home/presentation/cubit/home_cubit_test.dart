import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../home_test_helpers.dart';

void main() {
  late FakeGetCategories categories;
  late FakeGetProducts products;
  late FakeGetOrders orders;
  late HomeCubit cubit;

  setUp(() {
    categories = FakeGetCategories();
    products = FakeGetProducts();
    orders = FakeGetOrders();
    cubit = HomeCubit(
      getDashboardStats: GetDashboardStats(
        getCategories: categories,
        getProducts: products,
        getOrders: orders,
      ),
    );
  });

  tearDown(() => cubit.close());

  test('starts in HomeInitial', () {
    expect(cubit.state, isA<HomeInitial>());
  });

  test('load emits Loading then Loaded with the numbers', () async {
    products.result = Right([buildProduct('p1'), buildProduct('p2')]);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<HomeLoading>(),
        isA<HomeLoaded>().having((s) => s.stats.productsCount, 'products', 2),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('load emits Loading then Error with the failure message', () async {
    orders.result = const Left(Failure('No internet connection'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<HomeLoading>(),
        isA<HomeError>().having(
          (s) => s.message,
          'message',
          'No internet connection',
        ),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('refresh replaces the numbers without showing Loading', () async {
    await cubit.load();
    products.result = Right([buildProduct('p1')]);

    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<HomeLoaded>()
            .having((s) => s.stats.productsCount, 'products', 1)
            .having((s) => s.actionError, 'actionError', isNull),
      ),
    );

    await cubit.refresh();
    await expectation;
  });

  test('a failed refresh keeps the old numbers and sets actionError', () async {
    products.result = Right([buildProduct('p1'), buildProduct('p2')]);
    await cubit.load();
    orders.result = const Left(Failure('Server error'));

    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<HomeLoaded>()
            .having((s) => s.stats.productsCount, 'products', 2)
            .having((s) => s.actionError, 'actionError', 'Server error'),
      ),
    );

    await cubit.refresh();
    await expectation;
  });

  test('a failed refresh before anything was loaded emits Error', () async {
    orders.result = const Left(Failure('Server error'));

    final expectation = expectLater(cubit.stream, emits(isA<HomeError>()));

    await cubit.refresh();
    await expectation;
  });
}
