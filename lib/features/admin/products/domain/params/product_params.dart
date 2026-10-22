/// Fields for creating or updating a product. The image is a file path,
/// so the domain stays free of Dio and Flutter.
class ProductParams {
  const ProductParams({
    required this.name,
    required this.price,
    required this.quantity,
    required this.categoryId,
    required this.isVisible,
    this.description,
    this.imagePath,
  });

  final String name;
  final double price;
  final int quantity;
  final int categoryId;
  final bool isVisible;

  /// Null or empty means "no description" (the server stores null).
  final String? description;

  /// Set only when the user picked a new image. Null keeps the old one.
  final String? imagePath;
}
