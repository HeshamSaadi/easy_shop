import 'package:easy_shop/apps/client/session/session_cubit.dart';
import 'package:easy_shop/features/client/auth/client_auth_injection.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/client/profile/client_profile_injection.dart';
import 'package:get_it/get_it.dart';

void initClient(GetIt sl) {
  registerClientAuth(sl);
  registerClientProfile(sl);
  _registerAuthExtras(sl);
  // Future features will be registered here:
  // registerClientCategories(sl);
  // registerClientProducts(sl);
  // registerClientCart(sl);
  // registerClientOrders(sl);
  // registerClientHome(sl);
}

/// Register and session pieces added on top of `registerClientAuth`.
void _registerAuthExtras(GetIt sl) {
  sl
    ..registerFactory(() => RegisterCubit(registerClient: sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerLazySingleton(
      () =>
          SessionCubit(restoreSession: sl(), logout: sl(), sessionEvents: sl()),
    );
}
