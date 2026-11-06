import 'package:easy_shop/features/admin/orders/data/models/order_model.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../order_json_fixture.dart';

void main() {
  test('parses the order, its client and its items', () {
    final order = OrderModel.fromJson(orderJson());

    expect(order.code, '0D8CKBZJ');
    expect(order.totalPrice, 300);
    expect(order.address, '45 El Tahrir Square, Cairo');
    expect(order.paymentMethod, PaymentMethod.card);
    expect(order.status, 'pending');
    expect(order.createdAt, DateTime.utc(2026, 10, 16, 20, 57, 40));
    expect(order.client.name, 'Omar Hassan');
    expect(order.items, hasLength(1));
    expect(order.items.first.product.name, 'Smart Watch');
    expect(order.items.first.product.categoryName, 'Electronics');
  });

  test('keeps the price paid in the order, not the product price', () {
    final order = OrderModel.fromJson(orderJson());

    expect(order.items.first.price, 300);
    expect(order.items.first.totalPrice, 300);
  });

  test('accepts latitude and longitude sent as strings', () {
    final order = OrderModel.fromJson(
      orderJson(latitude: '30.04', longitude: '31.23'),
    );

    expect(order.latitude, 30.04);
    expect(order.longitude, 31.23);
    expect(order.hasLocation, isTrue);
  });

  test('has no location when coordinates are missing', () {
    final order = OrderModel.fromJson(
      orderJson(latitude: null, longitude: null),
    );

    expect(order.hasLocation, isFalse);
  });

  test('falls back to unknown for an unexpected payment method', () {
    final order = OrderModel.fromJson(orderJson(paymentMethod: 'crypto'));

    expect(order.paymentMethod, PaymentMethod.unknown);
  });

  test('does not crash when nested objects are missing', () {
    final order = OrderModel.fromJson({'id': 2, 'code': 'ABC'});

    expect(order.items, isEmpty);
    expect(order.client.name, isEmpty);
    expect(order.paymentMethod, PaymentMethod.unknown);
  });
}
