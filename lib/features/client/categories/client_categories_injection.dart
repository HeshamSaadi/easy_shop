import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/client/categories/data/repositories/category_repository_impl.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client categories feature. Call from `initClient`.
void registerClientCategories(GetIt sl) {
  sl
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetCategories(sl<CategoryRepository>()));
}
