import 'package:easy_shop/features/client/orders/data/models/order_item_model.dart';
import 'package:easy_shop/features/client/orders/data/models/order_model.dart';
import 'package:easy_shop/features/client/orders/data/models/place_order_request_model.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/params/order_line.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../client_orders_test_helpers.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('parses the order and its items', () {
      final order = OrderModel.fromJson(clientOrderJson());

      expect(order.id, 12);
      expect(order.code, '66D1BJIY');
      expect(order.totalPrice, 1040);
      expect(order.address, 'Cairo, Egypt');
      expect(order.status, 'pending');
      expect(order.paymentMethod, PaymentMethod.cash);
      expect(order.latitude, 30.033333);
      expect(order.longitude, 31.233334);
      expect(order.hasLocation, isTrue);
      expect(order.items, hasLength(2));
    });

    test('uses created_at in UTC, not the Cairo local date', () {
      final order = OrderModel.fromJson(clientOrderJson());

      expect(order.createdAt, DateTime.utc(2026, 11, 6, 11, 27, 57));
    });

    test('accepts numbers sent as strings', () {
      final order = OrderModel.fromJson(
        clientOrderJson(
          overrides: {
            'id': '12',
            'total_price': '1040',
            'latitude': '30.04',
            'longitude': '31.23',
          },
        ),
      );

      expect(order.id, 12);
      expect(order.totalPrice, 1040);
      expect(order.latitude, 30.04);
      expect(order.longitude, 31.23);
    });

    test('reads card as the card payment method', () {
      final order = OrderModel.fromJson(
        clientOrderJson(overrides: {'payment_method': 'card'}),
      );

      expect(order.paymentMethod, PaymentMethod.card);
    });

    test('an unknown payment method is null', () {
      final order = OrderModel.fromJson(
        clientOrderJson(overrides: {'payment_method': 'bitcoin'}),
      );

      expect(order.paymentMethod, isNull);
    });

    test('keeps a status the app does not know', () {
      final order = OrderModel.fromJson(
        clientOrderJson(overrides: {'status': 'processing'}),
      );

      expect(order.status, 'processing');
      expect(order.isPending, isFalse);
    });

    test('has no location when the coordinates are null', () {
      final order = OrderModel.fromJson(
        clientOrderJson(overrides: {'latitude': null, 'longitude': null}),
      );

      expect(order.hasLocation, isFalse);
    });

    test('a created_at that is not text gives no date', () {
      final order = OrderModel.fromJson(
        clientOrderJson(overrides: {'created_at': 12345}),
      );

      expect(order.createdAt, isNull);
    });

    test('does not crash when fields and items are missing', () {
      final order = OrderModel.fromJson({'id': 2, 'code': 'ABC'});

      expect(order.code, 'ABC');
      expect(order.items, isEmpty);
      expect(order.address, '');
      expect(order.status, '');
      expect(order.totalPrice, 0);
      expect(order.paymentMethod, isNull);
      expect(order.createdAt, isNull);
    });
  });

  group('OrderItemModel.fromJson', () {
    test('keeps the price paid, not the product price', () {
      final item = OrderItemModel.fromJson(orderItemJson(price: 220));

      expect(item.price, 220);
      expect(item.quantity, 2);
      expect(item.totalPrice, 440);
    });

    test('reads only the product name, image and category name', () {
      final item = OrderItemModel.fromJson(orderItemJson());

      expect(item.productId, 32);
      expect(item.productName, 'Samsung A24');
      expect(item.categoryName, 'Mobile Phone');
      expect(item.imageUrl, 'https://example.com/product-32.png');
    });

    test('a missing product does not crash', () {
      final item = OrderItemModel.fromJson({
        'product_id': 5,
        'price': 10,
        'quantity': 1,
        'total_price': 10,
      });

      expect(item.productId, 5);
      expect(item.productName, '');
      expect(item.categoryName, '');
      expect(item.imageUrl, '');
    });
  });

  group('PlaceOrderRequestModel.toJson', () {
    test('builds the exact body the server expects', () {
      final json = PlaceOrderRequestModel(buildPlaceOrderParams()).toJson();

      expect(json, {
        'product_id': [32, 33],
        'quantity': [2, 1],
        'price': [220.0, 600.0],
        'address': 'Cairo, Egypt',
        'latitude': 30.033333,
        'longitude': 31.233334,
        'payment_method': 'cash',
      });
    });

    test('the three lists have the same length and the same order', () {
      final params = buildPlaceOrderParams(
        lines: const [
          OrderLine(productId: 1, quantity: 3, price: 10),
          OrderLine(productId: 2, quantity: 1, price: 20),
          OrderLine(productId: 3, quantity: 5, price: 30),
        ],
      );

      final json = PlaceOrderRequestModel(params).toJson();
      final ids = json['product_id'] as List;
      final quantities = json['quantity'] as List;
      final prices = json['price'] as List;

      expect(ids, hasLength(3));
      expect(quantities, hasLength(ids.length));
      expect(prices, hasLength(ids.length));
      // Position i of each list describes the same item.
      expect(ids[2], 3);
      expect(quantities[2], 5);
      expect(prices[2], 30);
    });

    test('sends card in lowercase', () {
      final json = PlaceOrderRequestModel(
        buildPlaceOrderParams(paymentMethod: PaymentMethod.card),
      ).toJson();

      expect(json['payment_method'], 'card');
    });
  });
}
