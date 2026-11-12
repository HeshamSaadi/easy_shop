import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

class GetCart {
  const GetCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, List<CartItemEntity>>> call() {
    return _repository.getCart();
  }
}
