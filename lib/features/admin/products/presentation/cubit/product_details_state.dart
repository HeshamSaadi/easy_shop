import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';

sealed class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(
    this.product, {
    this.isDeleting = false,
    this.actionError,
  });

  final ProductEntity product;

  /// True while the delete request is running.
  final bool isDeleting;

  /// Set when the delete failed. The product stays on screen and the UI
  /// shows this message in a SnackBar.
  final String? actionError;
}

class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.message);

  final String message;
}

/// The product was deleted. The screen closes and tells the list to reload.
class ProductDetailsDeleted extends ProductDetailsState {
  const ProductDetailsDeleted();
}
