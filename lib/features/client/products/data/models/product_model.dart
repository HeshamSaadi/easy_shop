import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.price,
    required super.stock,
    required super.categoryId,
    required super.categoryName,
    required super.isVisible,
    required super.imageUrl,
    required super.storeName,
    super.description,
  });

  /// The product object has the same shape in the list and in the details.
  /// It also holds the whole `admin` object (email, phone, national id...).
  /// Only `admin.business_name` is read here. The rest is ignored on purpose.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = parseMap(json['category']);
    final admin = parseMap(json['admin']);

    return ProductModel(
      id: parseInt(json['id']),
      name: _text(json['name']) ?? '',
      slug: _text(json['slug']) ?? '',
      price: parseDouble(json['price']),
      stock: parseInt(json['quantity']),
      categoryId: parseInt(json['category_id']),
      categoryName: _text(category['name']) ?? '',
      isVisible: parseBool(json['visible']),
      imageUrl: _text(json['image_url']) ?? '',
      storeName: _text(admin['business_name']) ?? '',
      description: _text(json['description']),
    );
  }

  /// Trimmed text, or null when the value is missing or empty.
  /// Unlike `as String?`, it never throws on a number or another type.
  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
