import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_product_entity.dart';

class CartProductModel extends CartProductEntity {
  const CartProductModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.price,
    required super.stock,
    required super.categoryName,
    required super.imageUrl,
    required super.storeName,
    required super.isVisible,
  });

  /// The product inside a cart item also holds the whole `admin` object
  /// (email, phone, national id...). Only `admin.business_name` is read.
  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    final category = parseMap(json['category']);
    final admin = parseMap(json['admin']);

    return CartProductModel(
      id: parseInt(json['id']),
      slug: _text(json['slug']) ?? '',
      name: _text(json['name']) ?? '',
      price: parseDouble(json['price']),
      stock: parseInt(json['quantity']),
      categoryName: _text(category['name']) ?? '',
      imageUrl: _text(json['image_url']) ?? '',
      storeName: _text(admin['business_name']) ?? '',
      isVisible: parseBool(json['visible']),
    );
  }

  /// Trimmed text, or null when missing or empty. Never throws on a number.
  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
