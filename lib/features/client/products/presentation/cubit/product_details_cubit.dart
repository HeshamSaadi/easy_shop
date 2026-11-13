import 'dart:math';

import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/add_to_cart.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/client/products/presentation/constants/product_details_strings.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required this.slug,
    required this._getProductDetails,
    required this._getCart,
    required this._addToCart,
  }) : super(const ProductDetailsLoading());

  final String slug;
  final GetProductDetails _getProductDetails;
  final GetCart _getCart;
  final AddToCart _addToCart;

  Future<void> load() async {
    emit(const ProductDetailsLoading());
    final result = await _getProductDetails(slug);
    if (isClosed) return;

    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  void increase() {
    final current = state;
    if (current is! ProductDetailsLoaded) return;
    if (current.quantity >= current.product.stock) return;
    emit(
      current.copyWith(
        quantity: current.quantity + 1,
        status: AddToCartStatus.idle,
      ),
    );
  }

  void decrease() {
    final current = state;
    if (current is! ProductDetailsLoaded) return;
    if (current.quantity <= 1) return;
    emit(
      current.copyWith(
        quantity: current.quantity - 1,
        status: AddToCartStatus.idle,
      ),
    );
  }

  Future<void> addToCart() async {
    final current = state;
    if (current is! ProductDetailsLoaded || !current.canAdd) return;

    final product = current.product;
    emit(current.copyWith(status: AddToCartStatus.adding));

    final cart = await _getCart();
    if (isClosed) return;

    final cartFailure = cart.fold<Failure?>((failure) => failure, (_) => null);
    if (cartFailure != null) {
      _fail(cartFailure.message);
      return;
    }

    final inCart = cart
        .getOrElse(() => const [])
        .where((item) => item.product.id == product.id)
        .fold<int>(0, (sum, item) => sum + item.quantity);
    final total = min(inCart + current.quantity, product.stock);

    if (total <= inCart) {
      _fail(ProductDetailsStrings.alreadyMax);
      return;
    }

    final result = await _addToCart(productId: product.id, quantity: total);
    if (isClosed) return;

    result.fold(
      (failure) => _fail(failure.message),
      (_) => emit(current.copyWith(status: AddToCartStatus.added)),
    );
  }

  void _fail(String message) {
    final current = state;
    if (current is! ProductDetailsLoaded) return;
    emit(current.copyWith(status: AddToCartStatus.idle, actionError: message));
  }
}
