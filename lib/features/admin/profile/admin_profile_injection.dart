import 'package:easy_shop/features/admin/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/admin/profile/data/repositories/profile_repository_impl.dart';
import 'package:easy_shop/features/admin/profile/domain/entities/profile_entity.dart';
import 'package:easy_shop/features/admin/profile/domain/repositories/profile_repository.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/get_profile.dart';
import 'package:easy_shop/features/admin/profile/domain/usecases/update_profile.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:easy_shop/features/admin/profile/presentation/cubit/profile_cubit.dart';
import 'package:get_it/get_it.dart';

void registerAdminProfile(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetProfile(sl()))
    ..registerLazySingleton(() => UpdateProfile(sl()))
    ..registerFactory(() => ProfileCubit(sl()))
    ..registerFactoryParam<EditProfileCubit, ProfileEntity, void>(
      (profile, _) => EditProfileCubit(sl(), profile),
    );
}
