class OrderItemEntity {
  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  final int productId;
  final String productName;
  final String categoryName;
  final String imageUrl;

  /// The price at order time (the server stores the price the app sent).
  /// Show this, never the product's current price.
  final double price;
  final int quantity;
  final double totalPrice;
}
