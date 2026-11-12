import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/features/client/auth/client_auth_injection.dart';
import 'package:easy_shop/features/client/profile/client_profile_injection.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_shop/features/client/categories/client_categories_injection.dart';
import 'package:easy_shop/features/client/products/client_products_injection.dart';
import 'package:easy_shop/features/client/cart/client_cart_injection.dart';
import 'package:easy_shop/features/client/orders/client_orders_injection.dart';

/// Registers the Client features. Each feature adds its own
/// `registerClient...(sl)` call here (catalog, cart, orders, ...).
void initClient(GetIt sl) {
  registerClientAuth(sl);
  registerClientProfile(sl);
  registerClientCategories(sl);
  registerClientProducts(sl);
  registerClientCart(sl);
  registerClientOrders(sl);

  sl.registerLazySingleton(
    () => SessionCubit(restoreSession: sl(), logout: sl(), sessionEvents: sl()),
  );
}
