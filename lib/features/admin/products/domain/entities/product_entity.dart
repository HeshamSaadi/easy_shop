import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.isVisible,
    required this.imageUrl,
    this.description,
    this.category,
    this.createdAt,
  });

  final int id;
  final String name;

  /// Used in the details, update and delete paths. It changes when the
  /// product is renamed.
  final String slug;
  final double price;
  final int quantity;
  final int categoryId;
  final bool isVisible;
  final String imageUrl;
  final String? description;

  /// Null after create and update, because the server does not return it.
  final ProductCategoryEntity? category;
  final DateTime? createdAt;
}
