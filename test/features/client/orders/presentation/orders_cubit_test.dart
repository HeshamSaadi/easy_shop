import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../client_orders_test_helpers.dart';

void main() {
  late FakeClientOrdersRepository repository;
  late OrdersCubit cubit;

  setUp(() {
    repository = FakeClientOrdersRepository();
    cubit = OrdersCubit(getOrders: GetOrders(repository));
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('emits Loading and then Loaded with the orders', () async {
      repository.ordersResult = Right([buildOrder(code: 'A1')]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrdersLoading>(),
          isA<OrdersLoaded>().having(
            (s) => s.orders.map((o) => o.code).toList(),
            'codes',
            ['A1'],
          ),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('an empty list is Loaded with no orders, not an error', () async {
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

    test('emits Error with the failure message', () async {
      repository.ordersResult = const Left(Failure('No internet'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrdersLoading>(),
          isA<OrdersError>().having((s) => s.message, 'message', 'No internet'),
        ]),
      );
      await cubit.load();
      await expectation;
    });
  });

  group('refresh', () {
    test('does not emit Loading, so the old list stays on screen', () async {
      repository.ordersResult = Right([buildOrder(code: 'A1')]);
      await cubit.load();

      repository.ordersResult = Right([
        buildOrder(code: 'B2'),
        buildOrder(code: 'A1'),
      ]);
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrdersLoaded>().having((s) => s.orders.length, 'length', 2),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh keeps the list and sets actionError', () async {
      repository.ordersResult = Right([buildOrder(code: 'A1')]);
      await cubit.load();

      repository.ordersResult = const Left(Failure('Server error'));
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrdersLoaded>()
              .having((s) => s.orders.length, 'length', 1)
              .having((s) => s.actionError, 'actionError', 'Server error'),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh with no list yet emits Error', () async {
      repository.ordersResult = const Left(Failure('Server error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OrdersError>().having(
            (s) => s.message,
            'message',
            'Server error',
          ),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('a successful refresh clears an earlier actionError', () async {
      repository.ordersResult = Right([buildOrder()]);
      await cubit.load();
      repository.ordersResult = const Left(Failure('Server error'));
      await cubit.refresh();

      repository.ordersResult = Right([buildOrder()]);
      await cubit.refresh();

      final state = cubit.state;
      expect(state, isA<OrdersLoaded>());
      expect((state as OrdersLoaded).actionError, isNull);
    });
  });
}
