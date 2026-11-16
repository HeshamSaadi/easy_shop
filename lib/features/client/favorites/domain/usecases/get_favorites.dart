import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoriteRepository _repository;

  Future<Either<Failure, List<ProductEntity>>> call() async {
    final result = await _repository.getFavorites();
    return result.map(
      (products) => products.where((product) => product.isVisible).toList(),
    );
  }
}
