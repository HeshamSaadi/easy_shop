import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({required this._getProductDetails, required this.slug})
    : super(const ProductDetailsInitial());

  final GetProductDetails _getProductDetails;
  final String slug;

  Future<void> load() async {
    emit(const ProductDetailsLoading());
    final result = await _getProductDetails(slug);
    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }
}
