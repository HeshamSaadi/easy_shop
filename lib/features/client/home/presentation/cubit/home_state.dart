import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

sealed class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    this.query = '',
    this.refreshError,
  });

  final List<CategoryEntity> categories;
  final List<ProductEntity> products;

  final int? selectedCategoryId;
  final String query;

  final String? refreshError;

  List<ProductEntity> get visibleProducts {
    final text = query.trim().toLowerCase();
    return products.where((product) {
      final inCategory =
          selectedCategoryId == null ||
          product.categoryId == selectedCategoryId;
      final matchesText =
          text.isEmpty ||
          product.name.toLowerCase().contains(text) ||
          product.categoryName.toLowerCase().contains(text);
      return inCategory && matchesText;
    }).toList();
  }

  HomeLoaded withCategory(int? categoryId) {
    return HomeLoaded(
      categories: categories,
      products: products,
      selectedCategoryId: categoryId,
      query: query,
    );
  }

  HomeLoaded withQuery(String value) {
    return HomeLoaded(
      categories: categories,
      products: products,
      selectedCategoryId: selectedCategoryId,
      query: value,
    );
  }

  HomeLoaded withRefreshError(String message) {
    return HomeLoaded(
      categories: categories,
      products: products,
      selectedCategoryId: selectedCategoryId,
      query: query,
      refreshError: message,
    );
  }
}
