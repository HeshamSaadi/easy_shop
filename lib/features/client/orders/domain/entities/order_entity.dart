import 'package:easy_shop/features/client/orders/domain/entities/order_item_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.code,
    required this.totalPrice,
    required this.address,
    required this.status,
    required this.items,
    this.paymentMethod,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  final int id;

  /// Used in the details path. Orders are addressed by code, not by id.
  final String code;
  final double totalPrice;

  /// Delivery address of this order.
  final String address;
  final double? latitude;
  final double? longitude;

  /// Null when the server sends a value other than `cash` or `card`.
  final PaymentMethod? paymentMethod;

  /// Raw server value. Only `pending` and `processing` have been seen, so it
  /// is not forced into an enum.
  final String status;

  /// UTC. Convert to the device time zone when displaying.
  final DateTime? createdAt;
  final List<OrderItemEntity> items;

  /// True when "View on Map" can be shown.
  bool get hasLocation => latitude != null && longitude != null;

  bool get isPending => status.trim().toLowerCase() == 'pending';
}
