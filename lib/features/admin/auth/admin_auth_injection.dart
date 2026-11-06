import 'package:easy_shop/features/admin/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/admin/auth/data/repositories/auth_repository_impl.dart';
import 'package:easy_shop/features/admin/auth/domain/repositories/auth_repository.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/login_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/logout_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/register_admin.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/otp_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Admin auth feature. `admin_injection.dart` (A9) calls this
/// after `initCore`, because it needs ApiConsumer, TokenStorage and
/// SessionEvents from core.
void registerAdminAuth(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => LoginAdmin(sl()))
    ..registerLazySingleton(() => RegisterAdmin(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => ResendOtp(sl()))
    ..registerLazySingleton(() => LogoutAdmin(sl()))
    ..registerFactory(() => LoginCubit(loginAdmin: sl()))
    ..registerFactoryParam<OtpCubit, String, void>(
      (email, _) => OtpCubit(email: email, verifyOtp: sl(), resendOtp: sl()),
    );
}
