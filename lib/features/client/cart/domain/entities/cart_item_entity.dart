import 'package:easy_shop/features/client/cart/domain/entities/cart_product_entity.dart';

class CartItemEntity {
  const CartItemEntity({required this.product, required this.quantity});

  final CartProductEntity product;
  final int quantity;

  /// The cart has no price field, so the price is always the product's.
  double get lineTotal => product.price * quantity;

  /// The server does not check stock in the cart, so the app flags it.
  bool get exceedsStock => quantity > product.stock;

  /// The server accepts hidden products, so the app flags them.
  bool get isHidden => !product.isVisible;
}
