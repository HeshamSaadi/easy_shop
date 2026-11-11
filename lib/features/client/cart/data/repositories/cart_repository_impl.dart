import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/client/cart/data/datasources/cart_remote_data_source.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._remote);

  final CartRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart() {
    return guardedCall(_remote.getCart);
  }

  @override
  Future<Either<Failure, Unit>> setQuantity({
    required int productId,
    required int quantity,
  }) {
    return guardedUnitCall(
      () => _remote.setQuantity(productId: productId, quantity: quantity),
    );
  }

  @override
  Future<Either<Failure, Unit>> removeFromCart(int productId) {
    return guardedUnitCall(() => _remote.removeFromCart(productId));
  }
}
