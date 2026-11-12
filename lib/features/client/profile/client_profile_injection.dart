import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/client/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/client/profile/data/repositories/profile_repository_impl.dart';
import 'package:easy_shop/features/client/profile/domain/repositories/profile_repository.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/update_client_profile.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/client/profile/presentation/cubit/profile_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client profile feature.
void registerClientProfile(GetIt sl) {
  sl
    ..registerLazySingleton<ImagePickerService>(
      () => GalleryImagePickerService(),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetClientProfile(sl()))
    ..registerLazySingleton(() => UpdateClientProfile(sl()))
    ..registerFactory(() => ProfileCubit(getClientProfile: sl()))
    ..registerFactory(() => EditProfileCubit(updateClientProfile: sl()));
}
