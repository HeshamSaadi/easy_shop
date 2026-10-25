import 'package:easy_shop/apps/admin/session/session_cubit.dart';
import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/data/repositories/auth_repository_impl.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/register_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:get_it/get_it.dart';

void initAdmin(GetIt sl) {
  _initAuth(sl);
}

void _initAuth(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => RegisterAdmin(sl()))
    ..registerLazySingleton(() => LoginAdmin(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => ResendOtp(sl()))
    ..registerLazySingleton(() => LogoutAdmin(sl()))
    ..registerFactory(() => LoginCubit(sl()))
    ..registerFactory(() => RegisterCubit(sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerLazySingleton(
      () =>
          SessionCubit(restoreSession: sl(), logout: sl(), sessionEvents: sl()),
    );
}
