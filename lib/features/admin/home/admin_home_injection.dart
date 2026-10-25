import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/home/domain/usecases/get_dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:get_it/get_it.dart';

/// Registers the Admin home feature. Call it after categories, products and
/// orders are registered, because it reuses their list use cases.
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
