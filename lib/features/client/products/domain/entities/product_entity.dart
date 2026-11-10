class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.categoryName,
    required this.isVisible,
    required this.imageUrl,
    required this.storeName,
    this.description,
  });

  final int id;
  final String name;

  /// Used in the details path.
  final String slug;
  final double price;

  /// Units in stock. The API calls it `quantity`.
  final int stock;
  final int categoryId;
  final String categoryName;
  final bool isVisible;
  final String imageUrl;

  /// Store name of the seller (`admin.business_name`).
  final String storeName;
  final String? description;

  bool get inStock => stock > 0;
}
