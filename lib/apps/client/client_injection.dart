import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/features/client/auth/client_auth_injection.dart';
import 'package:easy_shop/features/client/profile/client_profile_injection.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client features. Each feature adds its own
/// `registerClient...(sl)` call here (catalog, cart, orders, favorites later).
void initClient(GetIt sl) {
  registerClientAuth(sl);
  registerClientProfile(sl);

  sl.registerLazySingleton(
    () => SessionCubit(restoreSession: sl(), logout: sl(), sessionEvents: sl()),
  );
}
