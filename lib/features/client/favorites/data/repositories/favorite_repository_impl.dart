import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/errors/guarded_call.dart';
import 'package:easy_shop/features/client/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  const FavoriteRepositoryImpl(this._remote);

  final FavoriteRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() {
    return guardedCall(_remote.getFavorites);
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(int productId) {
    return guardedUnitCall(() => _remote.addFavorite(productId));
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int productId) {
    return guardedUnitCall(() => _remote.removeFavorite(productId));
  }
}
