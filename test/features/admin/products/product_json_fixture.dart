/// A product shaped like the list and details responses
/// (see docs/admin-api-shapes.md).
Map<String, dynamic> productJson({
  Object? visible = 1,
  String? description = 'Premium wireless headphones',
}) {
  return {
    'id': 9,
    'name': 'Smart Watch',
    'slug': 'smart-watch',
    'price': 150,
    'quantity': 10,
    'category_id': 2,
    'description': description,
    'visible': visible,
    'admin_id': 3,
    'image_url': 'https://example.com/watch.png',
    'created_at': '2026-10-16T20:57:40.000000Z',
    'updated_at': '2026-10-16T20:57:40.000000Z',
    'category': {
      'id': 2,
      'name': 'Electronics',
      'slug': 'electronics',
      'description': null,
      'created_at': '2026-10-10T10:00:00.000000Z',
      'updated_at': '2026-10-10T10:00:00.000000Z',
    },
  };
}

/// A product shaped like the create and update responses: numbers arrive as
/// strings and there is no `category` object.
Map<String, dynamic> createdProductJson() {
  return {
    'id': 9,
    'name': 'Smart Watch',
    'slug': 'smart-watch',
    'price': '150',
    'quantity': '10',
    'category_id': '2',
    'description': null,
    'visible': '1',
    'admin_id': 3,
    'image_url': 'https://example.com/watch.png',
    'created_at': '2026-10-16T20:57:40.000000Z',
    'updated_at': '2026-10-16T20:57:40.000000Z',
  };
}
