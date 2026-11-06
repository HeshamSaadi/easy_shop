import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/products/data/models/product_category_model.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.price,
    required super.quantity,
    required super.categoryId,
    required super.isVisible,
    required super.imageUrl,
    super.description,
    super.category,
    super.createdAt,
  });

  /// Works for list, details, create and update responses. Create and update
  /// send numbers as strings and have no `category`, so every field is
  /// parsed tolerantly.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final createdAt = json['created_at'];

    return ProductModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: parseDouble(json['price']),
      quantity: parseInt(json['quantity']),
      categoryId: parseInt(json['category_id']),
      isVisible: parseBool(json['visible']),
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String?,
      category: category is Map<String, dynamic>
          ? ProductCategoryModel.fromJson(category)
          : null,
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
    );
  }
}
