/// An order shaped like the real response (see docs/admin-api-shapes.md).
/// The item price (300) differs from the product price (150) on purpose.
Map<String, dynamic> orderJson({
  Object? latitude = 30.04,
  Object? longitude = 31.23,
  Object? paymentMethod = 'card',
}) {
  return {
    'id': 1,
    'code': '0D8CKBZJ',
    'date': '2026-10-16 23:57:40',
    'created_at': '2026-10-16T20:57:40.000000Z',
    'updated_at': '2026-10-16T20:57:40.000000Z',
    'client_id': 5,
    'total_price': 300,
    'address': '45 El Tahrir Square, Cairo',
    'latitude': latitude,
    'longitude': longitude,
    'payment_method': paymentMethod,
    'status': 'pending',
    'payment': null,
    'client': {
      'id': 5,
      'name': 'Omar Hassan',
      'email': 'omar@example.com',
      'phone': '+201018765432',
      'address': null,
      'latitude': null,
      'longitude': null,
    },
    'order_items': [
      {
        'id': 1,
        'order_id': 1,
        'product_id': 9,
        'price': 300,
        'quantity': 1,
        'total_price': 300,
        'product': {
          'id': 9,
          'name': 'Smart Watch',
          'slug': 'smart-watch',
          'price': 150,
          'quantity': 10,
          'category_id': 2,
          'visible': 1,
          'image_url': 'https://example.com/watch.png',
          'category': {'id': 2, 'name': 'Electronics', 'slug': 'electronics'},
        },
      },
    ],
  };
}
