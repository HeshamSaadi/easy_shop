import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCart();

  /// Sets the quantity of a product to [quantity] (it replaces, not adds).
  Future<Either<Failure, Unit>> setQuantity({
    required int productId,
    required int quantity,
  });

  Future<Either<Failure, Unit>> removeFromCart(int productId);
}
