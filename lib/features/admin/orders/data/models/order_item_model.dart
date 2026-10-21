import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/orders/data/models/order_product_model.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.price,
    required super.quantity,
    required super.totalPrice,
    required super.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: parseInt(json['id']),
      price: parseDouble(json['price']),
      quantity: parseInt(json['quantity']),
      totalPrice: parseDouble(json['total_price']),
      product: OrderProductModel.fromJson(parseMap(json['product'])),
    );
  }
}
