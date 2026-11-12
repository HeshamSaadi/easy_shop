/// The part of a product the cart needs.
/// Defined here on purpose: a feature never imports another feature's data.
class CartProductEntity {
  const CartProductEntity({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.stock,
    required this.categoryName,
    required this.imageUrl,
    required this.storeName,
    required this.isVisible,
  });

  final int id;
  final String slug;
  final String name;
  final double price;
  final int stock;
  final String categoryName;
  final String imageUrl;
  final String storeName;
  final bool isVisible;
}
