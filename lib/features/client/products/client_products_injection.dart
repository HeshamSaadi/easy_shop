import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/products/data/datasources/product_remote_data_source.dart';
import 'package:easy_shop/features/client/products/data/repositories/product_repository_impl.dart';
import 'package:easy_shop/features/client/products/domain/repositories/product_repository.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:get_it/get_it.dart';

/// Registers the Client products feature. Call from `initClient`.
void registerClientProducts(GetIt sl) {
  sl
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetProducts(sl<ProductRepository>()))
    ..registerLazySingleton(() => GetProductDetails(sl<ProductRepository>()));
}
