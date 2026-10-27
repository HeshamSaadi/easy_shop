import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_client_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/admin/orders/domain/usecases/get_orders.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';

OrderEntity buildOrder({
  required String code,
  String status = 'pending',
  DateTime? createdAt,
}) {
  return OrderEntity(
    id: 1,
    code: code,
    totalPrice: 100,
    address: 'Cairo',
    paymentMethod: PaymentMethod.cash,
    status: status,
    client: const OrderClientEntity(
      id: 1,
      name: 'Omar',
      email: 'omar@example.com',
      phone: '+201000000000',
    ),
    items: const [],
    createdAt: createdAt,
  );
}

ProductEntity buildProduct(String name) {
  return ProductEntity(
    id: 1,
    name: name,
    slug: name,
    price: 10,
    quantity: 5,
    categoryId: 1,
    isVisible: true,
    imageUrl: '',
  );
}

CategoryEntity buildCategory(String name) {
  return CategoryEntity(id: 1, name: name, slug: name);
}

class FakeGetCategories implements GetCategories {
  Either<Failure, List<CategoryEntity>> result = const Right([]);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call() async => result;
}

class FakeGetProducts implements GetProducts {
  Either<Failure, List<ProductEntity>> result = const Right([]);

  @override
  Future<Either<Failure, List<ProductEntity>>> call() async => result;
}

class FakeGetOrders implements GetOrders {
  Either<Failure, List<OrderEntity>> result = const Right([]);

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async => result;
}
