import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({required this._getProducts}) : super(const ProductsInitial());

  final GetProducts _getProducts;

  Future<void> load() async {
    emit(const ProductsLoading());
    final result = await _getProducts();
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  /// Pull to refresh and reload after add/edit/delete: keeps the old list
  /// and the search text on screen while loading.
  Future<void> refresh() async {
    final query = switch (state) {
      ProductsLoaded(:final query) => query,
      _ => '',
    };
    final result = await _getProducts();
    result.fold(
      (failure) => _keepListWithError(failure.message),
      (products) => emit(ProductsLoaded(products, query: query)),
    );
  }

  void search(String query) {
    final current = state;
    if (current is! ProductsLoaded) return;
    emit(ProductsLoaded(current.products, query: query));
  }

  void _keepListWithError(String message) {
    final current = state;
    if (current is ProductsLoaded) {
      emit(
        ProductsLoaded(
          current.products,
          query: current.query,
          actionError: message,
        ),
      );
    } else {
      emit(ProductsError(message));
    }
  }
}
