import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:easy_shop/features/client/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:easy_shop/features/client/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../products/product_test_helpers.dart';

class _FakeFavoriteRemoteDataSource implements FavoriteRemoteDataSource {
  List<ProductModel> favorites = [];
  AppException? error;
  bool unexpectedError = false;
  int? lastAdded;
  int? lastRemoved;

  void _throwIfNeeded() {
    final appError = error;
    if (appError != null) throw appError;
    if (unexpectedError) throw StateError('unexpected');
  }

  @override
  Future<List<ProductModel>> getFavorites() async {
    _throwIfNeeded();
    return favorites;
  }

  @override
  Future<void> addFavorite(int productId) async {
    _throwIfNeeded();
    lastAdded = productId;
  }

  @override
  Future<void> removeFavorite(int productId) async {
    _throwIfNeeded();
    lastRemoved = productId;
  }
}

void main() {
  late _FakeFavoriteRemoteDataSource remote;
  late FavoriteRepositoryImpl repository;

  setUp(() {
    remote = _FakeFavoriteRemoteDataSource();
    repository = FavoriteRepositoryImpl(remote);
  });

  group('getFavorites', () {
    test('returns the products from the data source', () async {
      remote.favorites = [ProductModel.fromJson(clientProductJson())];

      final result = await repository.getFavorites();

      expect(result.getOrElse(() => []).single.id, 32);
    });

    test('turns an AppException into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.getFavorites();

      result.fold(
        (failure) => expect(failure.message, const ServerException().message),
        (_) => fail('expected a Failure'),
      );
    });

    test('turns an unexpected error into a Failure', () async {
      remote.unexpectedError = true;

      final result = await repository.getFavorites();

      result.fold(
        (failure) => expect(failure.message, const UnknownException().message),
        (_) => fail('expected a Failure'),
      );
    });
  });

  group('addFavorite', () {
    test('sends the product id to the data source', () async {
      final result = await repository.addFavorite(7);

      expect(result.isRight(), isTrue);
      expect(remote.lastAdded, 7);
    });

    test('turns an exception into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.addFavorite(7);

      expect(result.isLeft(), isTrue);
    });
  });

  group('removeFavorite', () {
    test('sends the product id to the data source', () async {
      final result = await repository.removeFavorite(7);

      expect(result.isRight(), isTrue);
      expect(remote.lastRemoved, 7);
    });

    test('turns an exception into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.removeFavorite(7);

      expect(result.isLeft(), isTrue);
    });
  });
}
