import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/admin/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/admin/categories/data/repositories/category_repository_impl.dart';
import 'package:easy_shop/features/admin/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/add_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/delete_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/update_category.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_cubit.dart';
import 'package:get_it/get_it.dart';

/// Call after `initCore`, from the admin app only.
void initCategories(GetIt sl) {
  sl
    ..registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSourceImpl(sl<ApiConsumer>()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetCategories(sl<CategoryRepository>()))
    ..registerLazySingleton(() => AddCategory(sl<CategoryRepository>()))
    ..registerLazySingleton(() => UpdateCategory(sl<CategoryRepository>()))
    ..registerLazySingleton(() => DeleteCategory(sl<CategoryRepository>()))
    ..registerFactory(
      () => CategoriesCubit(
        getCategories: sl<GetCategories>(),
        deleteCategory: sl<DeleteCategory>(),
      ),
    )
    ..registerFactory(
      () => CategoryFormCubit(
        addCategory: sl<AddCategory>(),
        updateCategory: sl<UpdateCategory>(),
      ),
    );
}
