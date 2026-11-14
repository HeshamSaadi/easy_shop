import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';

class AddFavorite {
  const AddFavorite(this._repository);

  final FavoriteRepository _repository;

  Future<Either<Failure, Unit>> call(int productId) {
    return _repository.addFavorite(productId);
  }
}
