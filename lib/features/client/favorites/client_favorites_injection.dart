import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:easy_shop/features/client/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/add_favorite.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/get_favorites.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/remove_favorite.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client favorites feature. Call from `initClient`.
/// The cubit is a singleton: the Favorites tab and the heart on the product
/// details screen show the same list.
void registerClientFavorites(GetIt sl) {
  sl
    ..registerLazySingleton<FavoriteRemoteDataSource>(
      () => FavoriteRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<FavoriteRepository>(
      () => FavoriteRepositoryImpl(sl<FavoriteRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetFavorites(sl<FavoriteRepository>()))
    ..registerLazySingleton(() => AddFavorite(sl<FavoriteRepository>()))
    ..registerLazySingleton(() => RemoveFavorite(sl<FavoriteRepository>()))
    ..registerLazySingleton(
      () => FavoritesCubit(
        getFavorites: sl<GetFavorites>(),
        addFavorite: sl<AddFavorite>(),
        removeFavorite: sl<RemoveFavorite>(),
      ),
    );
}
