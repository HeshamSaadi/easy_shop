import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../orders_test_helpers.dart';

void main() {
  late FakeOrdersRepository repository;
  late OrdersCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = OrdersCubit(getOrders: GetOrders(repository));
  });

  tearDown(() => cubit.close());

  test('starts in OrdersInitial', () {
    expect(cubit.state, isA<OrdersInitial>());
  });

  test('load emits Loading then Loaded with the orders', () async {
    repository.ordersResult = Right([
      buildOrder(),
      buildOrder(code: 'ORDER002'),
    ]);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrdersLoading>(),
        isA<OrdersLoaded>().having((s) => s.orders.length, 'orders', 2),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('load with no orders emits Loaded with an empty list', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrdersLoading>(),
        isA<OrdersLoaded>().having((s) => s.orders, 'orders', isEmpty),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('load emits Loading then Error with the failure message', () async {
    repository.ordersResult = const Left(Failure('No internet connection'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrdersLoading>(),
        isA<OrdersError>().having(
          (s) => s.message,
          'message',
          'No internet connection',
        ),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('refresh replaces the orders without showing Loading', () async {
    await cubit.load();
    repository.ordersResult = Right([buildOrder(code: 'NEW001')]);

    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<OrdersLoaded>()
            .having((s) => s.orders.single.code, 'code', 'NEW001')
            .having((s) => s.actionError, 'actionError', isNull),
      ),
    );

    await cubit.refresh();
    await expectation;
  });

  test('a failed refresh keeps the old orders and sets actionError', () async {
    repository.ordersResult = Right([
      buildOrder(),
      buildOrder(code: 'ORDER002'),
    ]);
    await cubit.load();
    repository.ordersResult = const Left(Failure('Server error'));

    final expectation = expectLater(
      cubit.stream,
      emits(
        isA<OrdersLoaded>()
            .having((s) => s.orders.length, 'orders', 2)
            .having((s) => s.actionError, 'actionError', 'Server error'),
      ),
    );

    await cubit.refresh();
    await expectation;
  });

  test('a failed refresh before anything was loaded emits Error', () async {
    repository.ordersResult = const Left(Failure('Server error'));

    final expectation = expectLater(cubit.stream, emits(isA<OrdersError>()));

    await cubit.refresh();
    await expectation;
  });
}
