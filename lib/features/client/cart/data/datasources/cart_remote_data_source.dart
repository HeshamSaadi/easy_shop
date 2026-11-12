import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/end_points.dart';
import 'package:easy_shop/core/databases/api/response_reader.dart';
import 'package:easy_shop/features/client/cart/data/models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCart();

  Future<void> setQuantity({required int productId, required int quantity});

  Future<void> removeFromCart(int productId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  const CartRemoteDataSourceImpl(this._api);

  static const String _productIdKey = 'product_id';
  static const String _quantityKey = 'quantity';

  final ApiConsumer _api;

  @override
  Future<List<CartItemModel>> getCart() async {
    final response = await _api.get(EndPoints.clientCart);
    return ResponseReader.list(response).map(CartItemModel.fromJson).toList();
  }

  /// `store` replaces the quantity and returns `data: null`,
  /// so there is nothing to read from the response.
  @override
  Future<void> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    await _api.post(
      EndPoints.clientCartStore,
      data: {_productIdKey: productId, _quantityKey: quantity},
    );
  }

  /// `DELETE` with a JSON body (the cart is addressed by `product_id`).
  @override
  Future<void> removeFromCart(int productId) async {
    await _api.delete(
      EndPoints.clientCartDestroy,
      data: {_productIdKey: productId},
    );
  }
}
