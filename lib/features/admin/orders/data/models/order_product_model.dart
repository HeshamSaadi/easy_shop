import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_product_entity.dart';

class OrderProductModel extends OrderProductEntity {
  const OrderProductModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.categoryName,
  });

  factory OrderProductModel.fromJson(Map<String, dynamic> json) {
    return OrderProductModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      categoryName: parseMap(json['category'])['name'] as String?,
    );
  }
}
