import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_client_entity.dart';

class OrderClientModel extends OrderClientEntity {
  const OrderClientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
  });

  factory OrderClientModel.fromJson(Map<String, dynamic> json) {
    return OrderClientModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}
