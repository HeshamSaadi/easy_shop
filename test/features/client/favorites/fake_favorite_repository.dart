import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

/// Hand-written fake: keeps the favorites in memory and never uses the
/// network. [products] is the catalog it can add from.
class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository({
    List<ProductEntity> favorites = const [],
    this.products = const [],
  }) : favorites = [...favorites];

  final List<ProductEntity> products;
  List<ProductEntity> favorites;

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() async {
    return Right([...favorites]);
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(int productId) async {
    if (favorites.any((product) => product.id == productId)) {
      return const Left(
        Failure('Product is already in your favorites', statusCode: 400),
      );
    }
    favorites = [
      ...favorites,
      ...products.where((product) => product.id == productId),
    ];
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int productId) async {
    favorites = favorites.where((product) => product.id != productId).toList();
    return const Right(unit);
  }
}
