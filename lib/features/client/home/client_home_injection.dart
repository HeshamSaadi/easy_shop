import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:get_it/get_it.dart';

void registerClientHome(GetIt sl) {
  sl.registerFactory(
    () => HomeCubit(
      getCategories: sl<GetCategories>(),
      getProducts: sl<GetProducts>(),
    ),
  );
}
