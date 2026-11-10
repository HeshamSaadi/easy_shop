import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/client/categories/data/repositories/category_repository_impl.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/client/products/data/datasources/product_remote_data_source.dart';
import 'package:easy_shop/features/client/products/data/repositories/product_repository_impl.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:get_it/get_it.dart';

/// Call from `initClient`, after `initCore`.
void registerClientCatalog(GetIt sl) {
  sl
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetCategories(sl<CategoryRepository>()))
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetProducts(sl<ProductRepository>()))
    ..registerLazySingleton(() => GetProductDetails(sl<ProductRepository>()));
}
