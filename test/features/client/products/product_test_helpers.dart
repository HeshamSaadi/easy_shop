import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

/// A product as the server returns it, with the private `admin` fields that
/// the app must never read.
Map<String, dynamic> clientProductJson({
  Map<String, dynamic> overrides = const {},
}) {
  return {
    'id': 32,
    'name': 'Samsung A24',
    'slug': 'samsung-a-24',
    'price': 150,
    'quantity': 12,
    'category_id': 5,
    'description': '6.5" Super AMOLED display',
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

ProductEntity buildProduct({
  int id = 1,
  String slug = 'product-1',
  bool isVisible = true,
  int stock = 10,
}) {
  return ProductEntity(
    id: id,
    name: 'Product $id',
    slug: slug,
    price: 100,
    stock: stock,
    categoryId: 5,
    categoryName: 'Mobile Phone',
    isVisible: isVisible,
    imageUrl: 'https://example.com/$id.png',
    storeName: 'Elbatal Store',
  );
}
