import 'package:easy_shop/features/admin/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../product_json_fixture.dart';

void main() {
  test('parses a list or details response, including the category', () {
    final product = ProductModel.fromJson(productJson());

    expect(product.id, 9);
    expect(product.name, 'Smart Watch');
    expect(product.slug, 'smart-watch');
    expect(product.price, 150);
    expect(product.quantity, 10);
    expect(product.categoryId, 2);
    expect(product.isVisible, isTrue);
    expect(product.imageUrl, 'https://example.com/watch.png');
    expect(product.description, 'Premium wireless headphones');
    expect(product.category?.name, 'Electronics');
    expect(product.createdAt, DateTime.utc(2026, 10, 16, 20, 57, 40));
  });

  test('visible 0 means the product is hidden', () {
    final product = ProductModel.fromJson(productJson(visible: 0));

    expect(product.isVisible, isFalse);
  });

  test('parses a create or update response: strings and no category', () {
    final product = ProductModel.fromJson(createdProductJson());

    expect(product.price, 150);
    expect(product.quantity, 10);
    expect(product.categoryId, 2);
    expect(product.isVisible, isTrue);
    expect(product.category, isNull);
  });

  test('keeps a missing description as null', () {
    final product = ProductModel.fromJson(productJson(description: null));

    expect(product.description, isNull);
  });

  test('an invalid created_at becomes null and does not crash', () {
    final json = productJson()..['created_at'] = 'not a date';

    final product = ProductModel.fromJson(json);

    expect(product.createdAt, isNull);
  });

  test('does not crash when fields are missing', () {
    final product = ProductModel.fromJson({'id': 3});

    expect(product.name, isEmpty);
    expect(product.imageUrl, isEmpty);
    expect(product.description, isNull);
    expect(product.category, isNull);
    expect(product.createdAt, isNull);
  });
}
