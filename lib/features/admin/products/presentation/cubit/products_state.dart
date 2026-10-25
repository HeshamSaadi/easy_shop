import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';

sealed class ProductsState {
  const ProductsState();
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// An empty [products] list is the "empty" screen, not a separate state.
class ProductsLoaded extends ProductsState {
  const ProductsLoaded(this.products, {this.query = '', this.actionError});

  /// Every product of the logged-in admin.
  final List<ProductEntity> products;

  /// Current search text. Filtering happens here, not on the server.
  final String query;

  /// Set when a refresh failed. The list stays on screen and the UI shows
  /// this message in a SnackBar.
  final String? actionError;

  /// [products] filtered by [query] (product name or category name).
  List<ProductEntity> get visibleProducts {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return products;
    return products.where((product) {
      final inName = product.name.toLowerCase().contains(needle);
      final inCategory =
          product.category?.name.toLowerCase().contains(needle) ?? false;
      return inName || inCategory;
    }).toList();
  }
}

class ProductsError extends ProductsState {
  const ProductsError(this.message);

  final String message;
}
