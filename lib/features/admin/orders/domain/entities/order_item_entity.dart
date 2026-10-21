import 'package:easy_shop/features/admin/orders/domain/entities/order_product_entity.dart';

class OrderItemEntity {
  const OrderItemEntity({
    required this.id,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.product,
  });

  final int id;

  /// Price at order time, sent by the client app. It can differ from the
  /// product's current price, so always show this one in order screens.
  final double price;
  final int quantity;
  final double totalPrice;
  final OrderProductEntity product;
}
