import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

sealed class FavoritesState {
  const FavoritesState();
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(
    this.products, {
    this.busyProductIds = const <int>{},
    this.actionError,
  });

  final List<ProductEntity> products;

  final Set<int> busyProductIds;

  final String? actionError;

  bool isFavorite(int productId) =>
      products.any((product) => product.id == productId);

  bool isBusy(int productId) => busyProductIds.contains(productId);

  FavoritesLoaded copyWith({
    List<ProductEntity>? products,
    Set<int>? busyProductIds,
    String? actionError,
  }) {
    return FavoritesLoaded(
      products ?? this.products,
      busyProductIds: busyProductIds ?? this.busyProductIds,
      actionError: actionError,
    );
  }
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.message);

  final String message;
}
