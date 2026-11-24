import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/repositories/favorite_repository.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/add_favorite.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/get_favorites.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/remove_favorite.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../products/product_test_helpers.dart';

class _StubFavoriteRepository implements FavoriteRepository {
  Either<Failure, List<ProductEntity>> listResult = const Right([]);
  Either<Failure, Unit> actionResult = const Right(unit);
  int? addedId;
  int? removedId;

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() async =>
      listResult;

  @override
  Future<Either<Failure, Unit>> addFavorite(int productId) async {
    addedId = productId;
    return actionResult;
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int productId) async {
    removedId = productId;
    return actionResult;
  }
}

void main() {
  late _StubFavoriteRepository repository;

  setUp(() => repository = _StubFavoriteRepository());

  group('GetFavorites', () {
    test('removes hidden products', () async {
      repository.listResult = Right([
        buildProduct(id: 1),
        buildProduct(id: 2, isVisible: false),
      ]);

      final result = await GetFavorites(repository)();

      final ids = result.getOrElse(() => []).map((p) => p.id).toList();
      expect(ids, [1]);
    });

    test('an empty list stays empty', () async {
      final result = await GetFavorites(repository)();

      expect(result.getOrElse(() => [buildProduct()]), isEmpty);
    });

    test('passes a failure through', () async {
      repository.listResult = const Left(Failure('No internet'));

      final result = await GetFavorites(repository)();

      result.fold(
        (failure) => expect(failure.message, 'No internet'),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('AddFavorite', () {
    test('sends the product id', () async {
      final result = await AddFavorite(repository)(7);

      expect(result.isRight(), isTrue);
      expect(repository.addedId, 7);
    });

    test('passes a failure through', () async {
      repository.actionResult = const Left(
        Failure('Product is already in your favorites'),
      );

      final result = await AddFavorite(repository)(7);

      result.fold(
        (failure) =>
            expect(failure.message, 'Product is already in your favorites'),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('RemoveFavorite', () {
    test('sends the product id', () async {
      final result = await RemoveFavorite(repository)(7);

      expect(result.isRight(), isTrue);
      expect(repository.removedId, 7);
    });

    test('passes a failure through', () async {
      repository.actionResult = const Left(Failure('Server error'));

      final result = await RemoveFavorite(repository)(7);

      expect(result.isLeft(), isTrue);
    });
  });
}
