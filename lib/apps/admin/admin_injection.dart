import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/features/admin/auth/admin_auth_injection.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/categories/admin_categories_injection.dart';
import 'package:easy_shop/features/admin/home/admin_home_injection.dart';
import 'package:easy_shop/features/admin/orders/admin_orders_injection.dart';
import 'package:easy_shop/features/admin/products/admin_products_injection.dart';
import 'package:get_it/get_it.dart';

void initAdmin(GetIt sl) {
  registerAdminAuth(sl);
  _registerAuthExtras(sl);
  registerAdminCategories(sl);
  registerAdminProducts(sl);
  registerAdminOrders(sl);
  registerAdminHome(sl);
}

/// Register and session pieces added in A9, on top of `registerAdminAuth`.
void _registerAuthExtras(GetIt sl) {
  sl
    ..registerFactory(() => RegisterCubit(sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerLazySingleton(
      () =>
          SessionCubit(restoreSession: sl(), logout: sl(), sessionEvents: sl()),
    );
}
