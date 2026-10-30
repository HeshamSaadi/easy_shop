import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_cubit.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../orders_test_helpers.dart';

void main() {
  const code = 'ORDER001';

  late FakeOrdersRepository repository;
  late OrderDetailsCubit cubit;

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = OrderDetailsCubit(
      getOrderDetails: GetOrderDetails(repository),
      code: code,
    );
  });

  tearDown(() => cubit.close());

  test('starts in OrderDetailsInitial', () {
    expect(cubit.state, isA<OrderDetailsInitial>());
  });

  test('load emits Loading then Loaded with the order', () async {
    repository.orderResult = Right(buildOrder(code: code));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<OrderDetailsLoading>(),
        isA<OrderDetailsLoaded>().having((s) => s.order.code, 'code', code),
      ]),
    );

    await cubit.load();
    await expectation;
  });

  test('load asks the repository for the order code it was given', () async {
    await cubit.load();

    expect(repository.requestedCode, code);
  });

  test('load emits Loading then Error with the failure message', () async {
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
}
