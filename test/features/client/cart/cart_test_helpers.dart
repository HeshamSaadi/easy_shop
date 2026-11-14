import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

CartItemEntity buildCartItem({
  int productId = 1,
  int quantity = 1,
  double price = 100,
  int stock = 10,
  bool isVisible = true,
  String name = 'Samsung A24',
}) {
  return CartItemEntity(
    quantity: quantity,
    product: CartProductEntity(
      id: productId,
      slug: 'product-$productId',
      name: name,
      price: price,
      stock: stock,
      categoryName: 'Mobile Phone',
      imageUrl: 'https://example.com/product-$productId.png',
      storeName: 'Elbatal Store',
      isVisible: isVisible,
    ),
  );
}

/// A product as the server returns it inside a cart item, including the
/// private `admin` fields that the app must never read.
Map<String, dynamic> cartProductJson({
  Map<String, dynamic> overrides = const {},
}) {
  return {
    'id': 32,
    'name': 'Samsung A24',
    'slug': 'samsung-a-24',
    'price': 150,
    'quantity': 40,
    'category_id': 5,
    'description': 'Phone',
    'visible': 1,
    'admin_id': 3,
    'image_url': 'https://example.com/a24.png',
    'category': {'id': 5, 'name': 'Mobile Phone', 'slug': 'mobile-phone'},
    'admin': {
      'id': 3,
      'business_name': 'Elbatal Store',
      'email': 'owner@example.com',
      'phone': '+201000000000',
      'national_id': '29801234567890',
    },
    ...overrides,
  };
}

Map<String, dynamic> cartItemJson({
  int quantity = 2,
  Map<String, dynamic>? product,
}) {
  return {
    'id': 9,
    'client_id': 1,
    'product_id': 32,
    'quantity': quantity,
    'product': product ?? cartProductJson(),
  };
}

Failure leftOf<T>(Either<Failure, T> result) {
  return result.fold((failure) => failure, (_) => fail('Expected a Left'));
}

T rightOf<T>(Either<Failure, T> result) {
  return result.fold((_) => fail('Expected a Right'), (value) => value);
}
