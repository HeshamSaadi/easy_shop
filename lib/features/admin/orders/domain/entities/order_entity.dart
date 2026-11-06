import 'package:easy_shop/features/admin/orders/domain/entities/order_client_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_item_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.code,
    required this.totalPrice,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.client,
    required this.items,
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  final int id;

  /// Used in the details path. Orders are addressed by code, not by id.
  final String code;
  final double totalPrice;

  /// Delivery address of this order (not the client's profile address).
  final String address;
  final double? latitude;
  final double? longitude;
  final PaymentMethod paymentMethod;

  /// Raw server value. Only `pending` has been seen, so the entity does not
  /// force it into an enum. Read-only for the admin (no endpoint to change it).
  final String status;

  /// UTC. Convert to the device time zone when displaying.
  final DateTime? createdAt;
  final OrderClientEntity client;
  final List<OrderItemEntity> items;

  /// True when "View on Map" can be shown.
  bool get hasLocation => latitude != null && longitude != null;

  /// Status is a raw String from the server, so compare it safely.
  bool get isPending => status.trim().toLowerCase() == 'pending';
}
