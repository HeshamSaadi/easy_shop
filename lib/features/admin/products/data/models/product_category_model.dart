import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_category_entity.dart';

class ProductCategoryModel extends ProductCategoryEntity {
  const ProductCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );
  }
}
