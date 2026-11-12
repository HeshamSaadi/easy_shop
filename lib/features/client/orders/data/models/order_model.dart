import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/orders/data/models/order_item_model.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.code,
    required super.totalPrice,
    required super.address,
    required super.status,
    required super.items,
    super.paymentMethod,
    super.latitude,
    super.longitude,
    super.createdAt,
  });

  /// The list, the details and the `store` response share this shape.
  /// The `payment` object is not parsed (its shape after paying is untested).
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'];

    return OrderModel(
      id: parseInt(json['id']),
      code: json['code']?.toString() ?? '',
      totalPrice: parseDouble(json['total_price']),
      address: json['address']?.toString() ?? '',
      latitude: parseNullableDouble(json['latitude']),
      longitude: parseNullableDouble(json['longitude']),
      paymentMethod: _paymentMethodFrom(json['payment_method']),
      status: json['status']?.toString() ?? '',
      createdAt: createdAt is String ? DateTime.tryParse(createdAt) : null,
      items: parseMapList(json['order_items'])
          .map(OrderItemModel.fromJson)
          .toList(),
    );
  }

  static PaymentMethod? _paymentMethodFrom(Object? value) {
    return switch (value) {
      'cash' => PaymentMethod.cash,
      'card' => PaymentMethod.card,
      _ => null,
    };
  }
}
