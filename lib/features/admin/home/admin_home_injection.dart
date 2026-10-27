import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:get_it/get_it.dart';

/// Registers the Admin home feature. It reuses the list use cases of categories, products and orders.
void registerAdminHome(GetIt sl) {
  sl
    ..registerLazySingleton(
      () => GetDashboardStats(
        getCategories: sl<GetCategories>(),
        getProducts: sl<GetProducts>(),
        getOrders: sl<GetOrders>(),
      ),
    )
    ..registerFactory(
      () => HomeCubit(getDashboardStats: sl<GetDashboardStats>()),
    );
}
