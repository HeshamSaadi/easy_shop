import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

abstract class FavoriteRepository {
  Future<Either<Failure, List<ProductEntity>>> getFavorites();

  Future<Either<Failure, Unit>> addFavorite(int productId);

  Future<Either<Failure, Unit>> removeFavorite(int productId);
}
