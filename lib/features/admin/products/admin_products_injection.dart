import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/products/data/datasources/products_remote_data_source.dart';
import 'package:easy_shop/features/admin/products/data/repositories/products_repository_impl.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/create_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/delete_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/update_product.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the Admin products feature. `admin_injection.dart` (A9) calls
/// this after `initCore`, because the data source needs ApiConsumer from core.
/// Cubits are factories: a new one per screen opening.
void registerAdminProducts(GetIt sl) {
  sl
    ..registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => GetProducts(sl()))
    ..registerLazySingleton(() => GetProductDetails(sl()))
    ..registerLazySingleton(() => CreateProduct(sl()))
    ..registerLazySingleton(() => UpdateProduct(sl()))
    ..registerLazySingleton(() => DeleteProduct(sl()))
    ..registerLazySingleton<ImagePickerService>(
      () => GalleryImagePickerService(),
    )
    ..registerFactory(() => ProductsCubit(getProducts: sl()))
    ..registerFactoryParam<ProductDetailsCubit, String, void>(
      (slug, _) => ProductDetailsCubit(
        getProductDetails: sl(),
        deleteProduct: sl(),
        slug: slug,
      ),
    )
    ..registerFactory(
      () => ProductFormCubit(
        getCategories: sl<GetCategories>(),
        createProduct: sl(),
        updateProduct: sl(),
        imagePicker: sl(),
      ),
    );
}
