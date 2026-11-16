import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.message);

  final String message;
}

/// [added] stays until the user changes the quantity, so the button keeps
/// showing "Added to Cart!".
enum AddToCartStatus { idle, adding, added }

class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(
    this.product, {
    this.quantity = 1,
    this.status = AddToCartStatus.idle,
    this.actionError,
  });

  final ProductEntity product;
  final int quantity;
  final AddToCartStatus status;

  final String? actionError;

  bool get canAdd => product.inStock && status == AddToCartStatus.idle;

  ProductDetailsLoaded copyWith({
    int? quantity,
    AddToCartStatus? status,
    String? actionError,
  }) {
    return ProductDetailsLoaded(
      product,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      actionError: actionError,
    );
  }
}
