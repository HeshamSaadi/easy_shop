import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/cart/domain/repositories/cart_repository.dart';

/// Sends the NEW TOTAL quantity of a product. The server replaces the
/// quantity, so the + and - buttons must send the new total, not the change.
class AddToCart {
  const AddToCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Unit>> call({
    required int productId,
    required int quantity,
  }) {
    return _repository.setQuantity(productId: productId, quantity: quantity);
  }
}
