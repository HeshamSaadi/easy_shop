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
  const ProductDetailsLoaded(this.product);

  final ProductEntity product;
}

class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.message);

  final String message;
}
