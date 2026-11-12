import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

class RemoveFromCart {
  const RemoveFromCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Unit>> call(int productId) {
    return _repository.removeFromCart(productId);
  }
}
