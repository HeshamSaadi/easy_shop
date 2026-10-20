import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_shop/core/connection/network_info.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/dio_consumer.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/databases/cache/secure_storage_helper.dart';
import 'package:easy_shop/core/databases/cache/cache_helper.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/core/utils/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initCore(GetIt sl, AppConfig config) async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<SessionEvents>(SessionEvents())
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<TokenStorage>(() => SecureStorageHelper(sl()))
    ..registerSingleton<CacheHelper>(CacheHelper(prefs))
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()))
    ..registerLazySingleton<ApiConsumer>(
      () => DioConsumer(
        dio: Dio(),
        config: sl(),
        tokenStorage: sl(),
        sessionEvents: sl(),
      ),
    );
}
