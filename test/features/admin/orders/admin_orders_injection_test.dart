import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/admin/orders/admin_orders_injection.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../helpers/fake_api_consumer.dart';

void main() {
  test('registerAdminOrders registers the repository and both use cases', () {
    final sl = GetIt.asNewInstance()
      ..registerSingleton<ApiConsumer>(FakeApiConsumer());

    registerAdminOrders(sl);

    expect(sl<OrdersRepository>(), isA<OrdersRepository>());
    expect(sl<GetOrders>(), isA<GetOrders>());
    expect(sl<GetOrderDetails>(), isA<GetOrderDetails>());
  });
}
