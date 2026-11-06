import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/features/admin/products/admin_products_injection.dart';
import 'package:easy_shop/features/admin/products/domain/repositories/products_repository.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/create_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/delete_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_products.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/update_product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Only needs to exist: nothing here is called, the test just resolves.
class _FakeApiConsumer implements ApiConsumer {
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  test('registerAdminProducts registers the repository and all use cases', () {
    // A separate container, so the test never touches the app's global one.
    final sl = GetIt.asNewInstance()
      ..registerSingleton<ApiConsumer>(_FakeApiConsumer());

    registerAdminProducts(sl);

    expect(sl<ProductsRepository>(), isA<ProductsRepository>());
    expect(sl<GetProducts>(), isA<GetProducts>());
    expect(sl<GetProductDetails>(), isA<GetProductDetails>());
    expect(sl<CreateProduct>(), isA<CreateProduct>());
    expect(sl<UpdateProduct>(), isA<UpdateProduct>());
    expect(sl<DeleteProduct>(), isA<DeleteProduct>());
  });
}
