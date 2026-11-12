import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

/// Hand-written fake: keeps the cart in memory and never uses the network.
class FakeCartRepository implements CartRepository {
  FakeCartRepository({List<CartItemEntity> items = const []})
    : items = [...items];

  List<CartItemEntity> items;

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() async {
    return Right([...items]);
  }

  @override
  Future<Either<Failure, Unit>> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    items = [
      for (final item in items)
        item.product.id == productId
            ? CartItemEntity(product: item.product, quantity: quantity)
            : item,
    ];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> removeFromCart(int productId) async {
    items = items.where((item) => item.product.id != productId).toList();
    return const Right(unit);
  }
}
