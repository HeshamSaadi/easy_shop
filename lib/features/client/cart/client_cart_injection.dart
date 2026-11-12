import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/client/cart/data/datasources/cart_remote_data_source.dart';
import 'package:easy_shop/features/client/cart/data/repositories/cart_repository_impl.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/remove_from_cart.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';

/// Registers the Client cart feature. Call from `initClient`.
void registerClientCart(GetIt sl) {
  sl
    ..registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetCart(sl<CartRepository>()))
    ..registerLazySingleton(() => AddToCart(sl<CartRepository>()))
    ..registerLazySingleton(() => RemoveFromCart(sl<CartRepository>()))
    ..registerLazySingleton(
      () => CartCubit(
        getCart: sl<GetCart>(),
        addToCart: sl<AddToCart>(),
        removeFromCart: sl<RemoveFromCart>(),
      ),
    );
}
