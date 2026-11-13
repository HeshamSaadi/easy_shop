import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_state.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_products.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef _Catalog = ({
  List<CategoryEntity> categories,
  List<ProductEntity> products,
});

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this._getCategories, required this._getProducts})
    : super(const HomeInitial());

  final GetCategories _getCategories;
  final GetProducts _getProducts;

  Future<void> load() async {
    emit(const HomeLoading());
    final result = await _fetch();
    if (isClosed) return;

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (catalog) => emit(
        HomeLoaded(categories: catalog.categories, products: catalog.products),
      ),
    );
  }

  Future<void> refresh() async {
    final result = await _fetch();
    if (isClosed) return;

    final latest = state;
    result.fold(
      (failure) {
        if (latest is HomeLoaded) {
          emit(latest.withRefreshError(failure.message));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (catalog) {
        final selected = latest is HomeLoaded
            ? latest.selectedCategoryId
            : null;
        final stillExists = catalog.categories.any((c) => c.id == selected);
        emit(
          HomeLoaded(
            categories: catalog.categories,
            products: catalog.products,
            selectedCategoryId: stillExists ? selected : null,
            query: latest is HomeLoaded ? latest.query : '',
          ),
        );
      },
    );
  }

  void selectCategory(int? categoryId) {
    final current = state;
    if (current is! HomeLoaded) return;
    emit(current.withCategory(categoryId));
  }

  void search(String query) {
    final current = state;
    if (current is! HomeLoaded) return;
    emit(current.withQuery(query));
  }

  Future<Either<Failure, _Catalog>> _fetch() async {
    final (categories, products) = await (
      _getCategories(),
      _getProducts(),
    ).wait;
    return categories.flatMap(
      (c) => products.map((p) => (categories: c, products: p)),
    );
  }
}
