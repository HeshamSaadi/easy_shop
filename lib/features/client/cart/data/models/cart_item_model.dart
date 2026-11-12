import 'package:easy_shop/core/utils/json_parsers.dart';
import 'package:easy_shop/features/client/cart/data/models/cart_product_model.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({required super.product, required super.quantity});

  /// Cart row: `quantity` and the full `product`. The cart row `id` is not
  /// read, because no request uses it (the cart is addressed by product id).
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: CartProductModel.fromJson(parseMap(json['product'])),
      quantity: parseInt(json['quantity']),
    );
  }
}
