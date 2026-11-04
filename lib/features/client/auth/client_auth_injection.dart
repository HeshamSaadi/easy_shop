import 'package:easy_shop/features/client/auth/data/datasources/auth_remote_data_source.dart';
import 'package:easy_shop/features/client/auth/data/repositories/auth_repository_impl.dart';
import 'package:easy_shop/features/client/auth/domain/repositories/auth_repository.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/login_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/logout_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/register_client.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/resend_otp.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/restore_session.dart';
import 'package:easy_shop/features/client/auth/domain/usecases/verify_otp.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/login_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/otp_cubit.dart';
import 'package:easy_shop/features/client/auth/presentation/cubit/register_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client auth feature.
/// Called after `initCore`, because it needs ApiConsumer, TokenStorage and
/// SessionEvents from core.
void registerClientAuth(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton(() => LoginClient(sl()))
    ..registerLazySingleton(() => RegisterClient(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => ResendOtp(sl()))
    ..registerLazySingleton(() => LogoutClient(sl()))
    ..registerLazySingleton(() => RestoreSession(sl()))
    ..registerFactory(() => LoginCubit(loginClient: sl()))
    ..registerFactory(() => RegisterCubit(registerClient: sl()))
    ..registerFactoryParam<OtpCubit, String, void>(
      (email, _) => OtpCubit(email: email, verifyOtp: sl(), resendOtp: sl()),
    );
}
