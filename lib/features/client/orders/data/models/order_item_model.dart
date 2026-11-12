import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.categoryName,
    required super.imageUrl,
    required super.price,
    required super.quantity,
    required super.totalPrice,
  });

  /// The nested product also holds the private `admin` object. It is never
  /// read here: only the name, the image and the category name are used.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = parseMap(json['product']);
    final category = parseMap(product['category']);

    return OrderItemModel(
      productId: parseInt(json['product_id']),
      productName: product['name']?.toString() ?? '',
      categoryName: category['name']?.toString() ?? '',
      imageUrl: product['image_url']?.toString() ?? '',
      price: parseDouble(json['price']),
      quantity: parseInt(json['quantity']),
      totalPrice: parseDouble(json['total_price']),
    );
  }
}
