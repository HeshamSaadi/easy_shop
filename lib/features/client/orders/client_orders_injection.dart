import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/orders/data/datasources/orders_remote_data_source.dart';
import 'package:easy_shop/features/client/orders/data/repositories/orders_repository_impl.dart';
import 'package:easy_shop/features/client/orders/domain/repositories/orders_repository.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/place_order.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client orders feature. Call from `initClient`.
void registerClientOrders(GetIt sl) {
  sl
    ..registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetOrders(sl<OrdersRepository>()))
    ..registerLazySingleton(() => GetOrderDetails(sl<OrdersRepository>()))
    ..registerLazySingleton(() => PlaceOrder(sl<OrdersRepository>()));
}
