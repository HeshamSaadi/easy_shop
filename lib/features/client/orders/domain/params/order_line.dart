/// One product in an order request.
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  final int productId;
  final int quantity;

  /// Must come from the cart item (`product.price`). The server trusts it.
  final double price;
}
