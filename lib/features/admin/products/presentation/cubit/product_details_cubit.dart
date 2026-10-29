import 'package:easy_shop/features/admin/products/domain/usecases/delete_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required this._getProductDetails,
    required this._deleteProduct,
    required this.slug,
  }) : super(const ProductDetailsInitial());

  final GetProductDetails _getProductDetails;
  final DeleteProduct _deleteProduct;
  final String slug;

  Future<void> load() async {
    emit(const ProductDetailsLoading());
    final result = await _getProductDetails(slug);
    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  Future<void> delete() async {
    final current = state;
    // No double submit: ignore taps while a delete is running
    if (current is! ProductDetailsLoaded || current.isDeleting) return;

    emit(ProductDetailsLoaded(current.product, isDeleting: true));

    final result = await _deleteProduct(current.product.slug);
    result.fold(
      (failure) => emit(
        ProductDetailsLoaded(current.product, actionError: failure.message),
      ),
      (_) => emit(const ProductDetailsDeleted()),
    );
  }
}
