import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/orders/data/models/order_client_model.dart';
import 'package:easy_shop/features/admin/orders/data/models/order_item_model.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.code,
    required super.totalPrice,
    required super.address,
    required super.paymentMethod,
    required super.status,
    required super.client,
    required super.items,
    super.latitude,
    super.longitude,
    super.createdAt,
  });

  /// The list and the details endpoints return the same object.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'];

    return OrderModel(
      id: parseInt(json['id']),
      code: json['code'] as String? ?? '',
      totalPrice: parseDouble(json['total_price']),
      address: json['address'] as String? ?? '',
      latitude: parseNullableDouble(json['latitude']),
      longitude: parseNullableDouble(json['longitude']),
      paymentMethod: _paymentMethodFrom(json['payment_method']),
      status: json['status'] as String? ?? '',
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
      client: OrderClientModel.fromJson(parseMap(json['client'])),
      items: parseMapList(json['order_items'])
          .map(OrderItemModel.fromJson)
          .toList(),
    );
  }

  static PaymentMethod _paymentMethodFrom(Object? value) {
    return switch (value) {
      'cash' => PaymentMethod.cash,
      'card' => PaymentMethod.card,
      _ => PaymentMethod.unknown,
    };
  }
}
