import 'package:easy_shop/features/client/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/client/profile/data/repositories/profile_repository_impl.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers all client profile-related dependencies.
void registerClientProfile(GetIt sl) {
  // Cubit
  sl.registerFactory(
    () => ProfileCubit(getClientProfile: sl(), updateClientProfile: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetClientProfile(sl()));
  sl.registerLazySingleton(() => UpdateClientProfile(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
}
