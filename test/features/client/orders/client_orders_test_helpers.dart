import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/order_item_entity.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/params/order_line.dart';
import 'package:easy_shop/features/client/orders/domain/params/place_order_params.dart';
import 'package:easy_shop/features/client/orders/domain/repositories/orders_repository.dart';

/// Hand-written fake. Set a result before the call, and [placeGate] to pause
/// `placeOrder` until the test completes it (for the no double submit tests).
class FakeClientOrdersRepository implements OrdersRepository {
  Either<Failure, List<OrderEntity>> ordersResult = const Right([]);
  Either<Failure, OrderEntity> orderResult = Right(buildOrder());
  Either<Failure, OrderEntity> placeResult = Right(buildOrder());

  Completer<void>? placeGate;

  /// The code the last [getOrder] call received.
  String? requestedCode;

  /// Every [placeOrder] call, so a test can count them and read the lines.
  final List<PlaceOrderParams> placedParams = [];

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async => ordersResult;

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String code) async {
    requestedCode = code;
    return orderResult;
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder(
    PlaceOrderParams params,
  ) async {
    placedParams.add(params);
    await placeGate?.future;
    return placeResult;
  }
}

OrderEntity buildOrder({
  String code = 'ORDER001',
  DateTime? createdAt,
  String status = 'pending',
  PaymentMethod? paymentMethod = PaymentMethod.cash,
  double? latitude = 30.033333,
  double? longitude = 31.233334,
}) {
  return OrderEntity(
    id: 1,
    code: code,
    totalPrice: 150,
    address: 'Cairo, Egypt',
    status: status,
    items: const [
      OrderItemEntity(
        productId: 1,
        productName: 'Samsung A24',
        categoryName: 'Mobile Phone',
        imageUrl: 'https://example.com/a24.png',
        price: 150,
        quantity: 1,
        totalPrice: 150,
      ),
    ],
    paymentMethod: paymentMethod,
    latitude: latitude,
    longitude: longitude,
    createdAt: createdAt,
  );
}

PlaceOrderParams buildPlaceOrderParams({
  List<OrderLine>? lines,
  PaymentMethod paymentMethod = PaymentMethod.cash,
}) {
  return PlaceOrderParams(
    lines:
        lines ??
        const [
          OrderLine(productId: 32, quantity: 2, price: 220),
          OrderLine(productId: 33, quantity: 1, price: 600),
        ],
    address: 'Cairo, Egypt',
    latitude: 30.033333,
    longitude: 31.233334,
    paymentMethod: paymentMethod,
  );
}

/// One item as the server returns it, with the private `admin` fields that
/// the app must never read.
Map<String, dynamic> orderItemJson({
  int productId = 32,
  num price = 220,
  int quantity = 2,
  String name = 'Samsung A24',
}) {
  return {
    'id': 1,
    'order_id': 12,
    'product_id': productId,
    'price': price,
    'quantity': quantity,
    'total_price': price * quantity,
    'product': {
      'id': productId,
      'name': name,
      'image_url': 'https://example.com/product-$productId.png',
      'category': {'id': 5, 'name': 'Mobile Phone'},
      'admin': {
        'id': 3,
        'business_name': 'Elbatal Store',
        'email': 'owner@example.com',
        'national_id': '29801234567890',
      },
    },
  };
}

/// An order as the server returns it (the list, the details and `store`
/// share this shape).
Map<String, dynamic> clientOrderJson({
  Map<String, dynamic> overrides = const {},
}) {
  return {
    'id': 12,
    'code': '66D1BJIY',
    'date': '2026-11-06 13:27:57',
    'created_at': '2026-11-06T11:27:57.000000Z',
    'client_id': 1,
    'total_price': 1040,
    'address': 'Cairo, Egypt',
    'latitude': 30.033333,
    'longitude': 31.233334,
    'payment_method': 'cash',
    'status': 'pending',
    'payment': null,
    'order_items': [
      orderItemJson(),
      orderItemJson(productId: 33, price: 600, quantity: 1, name: 'iPhone 14'),
    ],
    ...overrides,
  };
}
