import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/order_details_cubit.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../client_orders_test_helpers.dart';

void main() {
  late FakeClientOrdersRepository repository;
  late OrderDetailsCubit cubit;

  setUp(() {
    repository = FakeClientOrdersRepository();
    cubit = OrderDetailsCubit(
      code: 'ORDER001',
      getOrderDetails: GetOrderDetails(repository),
    );
  });

  tearDown(() => cubit.close());

  test('starts as Initial', () {
    expect(cubit.state, isA<OrderDetailsInitial>());
  });

  test('asks the repository for the order code it was created with', () async {
    await cubit.load();

    expect(repository.requestedCode, 'ORDER001');
  });

  test('emits Loading and then Loaded with the order', () async {
    repository.orderResult = Right(buildOrder(code: 'ORDER001'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrderDetailsLoading>(),
        isA<OrderDetailsLoaded>().having(
          (s) => s.order.code,
          'code',
          'ORDER001',
        ),
      ]),
    );
    await cubit.load();
    await expectation;
  });

  test('emits Error with the failure message', () async {
    repository.orderResult = const Left(Failure('Order is not found'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrderDetailsLoading>(),
        isA<OrderDetailsError>().having(
          (s) => s.message,
          'message',
          'Order is not found',
        ),
      ]),
    );
    await cubit.load();
    await expectation;
  });

  test('retry after an error loads the order again', () async {
    repository.orderResult = const Left(Failure('No internet'));
    await cubit.load();

    repository.orderResult = Right(buildOrder());
    await cubit.load();

    expect(cubit.state, isA<OrderDetailsLoaded>());
  });

  test('does not emit after the Cubit is closed', () async {
    final states = <OrderDetailsState>[];
    final subscription = cubit.stream.listen(states.add);

    final loading = cubit.load();
    await cubit.close();
    await loading;
    await subscription.cancel();

    expect(states.whereType<OrderDetailsLoaded>(), isEmpty);
  });
}
