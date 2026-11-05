import 'package:easy_shop/features/admin/orders/data/datasources/orders_remote_data_source.dart';
import 'package:easy_shop/features/admin/orders/data/repositories/orders_repository_impl.dart';
import 'package:easy_shop/features/admin/orders/domain/repositories/orders_repository.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_order_details.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_cubit.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/orders_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Admin orders feature. `admin_injection.dart` (A9) calls this
/// after `initCore`.
void registerAdminOrders(GetIt sl) {
  sl
    ..registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetOrders(sl()))
    ..registerLazySingleton(() => GetOrderDetails(sl()))
    ..registerFactory(() => OrdersCubit(getOrders: sl()))
    ..registerFactoryParam<OrderDetailsCubit, String, void>(
      (code, _) => OrderDetailsCubit(getOrderDetails: sl(), code: code),
    );
}
