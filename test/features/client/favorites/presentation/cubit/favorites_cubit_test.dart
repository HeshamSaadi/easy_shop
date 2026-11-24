import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/add_favorite.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/get_favorites.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/remove_favorite.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../products/product_test_helpers.dart';
import '../../fake_favorite_repository.dart';

/// The shared fake plus switches for the cases it cannot produce: a failing
/// list, a failing add or remove, and a pause gate on `addFavorite`.
class _ControlledFavoriteRepository extends FakeFavoriteRepository {
  _ControlledFavoriteRepository({super.favorites, super.products});

  Failure? listFailure;
  Failure? actionFailure;
  Completer<void>? gate;
  int addCalls = 0;
  int removeCalls = 0;

  @override
  Future<Either<Failure, List<ProductEntity>>> getFavorites() async {
    final failure = listFailure;
    if (failure != null) return Left(failure);
    return super.getFavorites();
  }

  @override
  Future<Either<Failure, Unit>> addFavorite(int productId) async {
    addCalls++;
    await gate?.future;
    final failure = actionFailure;
    if (failure != null) return Left(failure);
    return super.addFavorite(productId);
  }

  @override
  Future<Either<Failure, Unit>> removeFavorite(int productId) async {
    removeCalls++;
    final failure = actionFailure;
    if (failure != null) return Left(failure);
    return super.removeFavorite(productId);
  }
}

void main() {
  final first = buildProduct(id: 1, slug: 'first');
  final second = buildProduct(id: 2, slug: 'second');

  late _ControlledFavoriteRepository repository;
  late FavoritesCubit cubit;

  void createCubit({List<ProductEntity> favorites = const []}) {
    repository = _ControlledFavoriteRepository(
      favorites: favorites,
      products: [first, second],
    );
    cubit = FavoritesCubit(
      getFavorites: GetFavorites(repository),
      addFavorite: AddFavorite(repository),
      removeFavorite: RemoveFavorite(repository),
    );
  }

  setUp(createCubit);

  tearDown(() => cubit.close());

  group('load', () {
    test('emits Loading and then Loaded with the favorites', () async {
      createCubit(favorites: [first]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<FavoritesLoading>(),
          isA<FavoritesLoaded>().having(
            (s) => s.products.map((p) => p.id).toList(),
            'ids',
            [1],
          ),
        ]),
      );
      await cubit.load();
      await expectation;
    });

    test('emits Error with the failure message', () async {
      repository.listFailure = const Failure('No internet');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<FavoritesLoading>(),
          isA<FavoritesError>().having(
            (s) => s.message,
            'message',
            'No internet',
          ),
        ]),
      );
      await cubit.load();
      await expectation;
    });
  });

  group('refresh', () {
    test('does not emit Loading and replaces the list', () async {
      await cubit.load();
      repository.favorites = [first, second];

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<FavoritesLoaded>().having((s) => s.products.length, 'length', 2),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh keeps the list and sets actionError', () async {
      createCubit(favorites: [first]);
      await cubit.load();
      repository.listFailure = const Failure('Server error');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<FavoritesLoaded>()
              .having((s) => s.products.length, 'length', 1)
              .having((s) => s.actionError, 'actionError', 'Server error'),
        ]),
      );
      await cubit.refresh();
      await expectation;
    });

    test('a failed refresh with no list yet emits Error', () async {
      repository.listFailure = const Failure('Server error');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<FavoritesError>()]),
      );
      await cubit.refresh();
      await expectation;
    });
  });

  group('toggle', () {
    test('adds a product that is not a favorite', () async {
      await cubit.load();

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<FavoritesLoaded>().having((s) => s.busyProductIds, 'busy', {1}),
          isA<FavoritesLoaded>()
              .having((s) => s.isFavorite(1), 'isFavorite', isTrue)
              .having((s) => s.busyProductIds, 'busy', isEmpty),
        ]),
      );
      await cubit.toggle(first);
      await expectation;
      expect(repository.addCalls, 1);
    });

    test('removes a product that is already a favorite', () async {
      createCubit(favorites: [first]);
      await cubit.load();

      await cubit.toggle(first);

      final state = cubit.state as FavoritesLoaded;
      expect(state.isFavorite(1), isFalse);
      expect(repository.removeCalls, 1);
    });

    test('from Initial it loads the list and does not toggle', () async {
      await cubit.toggle(first);

      expect(cubit.state, isA<FavoritesLoaded>());
      expect(repository.addCalls, 0);
      expect((cubit.state as FavoritesLoaded).isFavorite(1), isFalse);
    });

    test('ignores a second tap on a product that is busy', () async {
      await cubit.load();
      repository.gate = Completer<void>();

      final firstTap = cubit.toggle(first);
      await pumpEventQueue();
      await cubit.toggle(first);
      repository.gate!.complete();
      await firstTap;

      expect(repository.addCalls, 1);
    });

    test('a failed add keeps the list and sets actionError', () async {
      await cubit.load();
      repository.actionFailure = const Failure('Server error', statusCode: 500);

      await cubit.toggle(first);

      final state = cubit.state as FavoritesLoaded;
      expect(state.isFavorite(1), isFalse);
      expect(state.busyProductIds, isEmpty);
      expect(state.actionError, 'Server error');
    });

    test('a 400 "already a favorite" is treated as success', () async {
      await cubit.load();
      // The server already has it, but the app did not know.
      repository.favorites = [first];
      repository.actionFailure = const Failure(
        'Product is already in your favorites',
        statusCode: 400,
      );

      await cubit.toggle(first);

      final state = cubit.state as FavoritesLoaded;
      expect(state.isFavorite(1), isTrue);
      expect(state.actionError, isNull);
      expect(state.busyProductIds, isEmpty);
    });

    test('a failed refetch after the change sets actionError', () async {
      await cubit.load();
      repository.listFailure = const Failure('No internet');

      await cubit.toggle(first);

      final state = cubit.state as FavoritesLoaded;
      expect(state.actionError, 'No internet');
      expect(state.busyProductIds, isEmpty);
    });

    test('a successful toggle clears an earlier actionError', () async {
      await cubit.load();
      repository.actionFailure = const Failure('Server error', statusCode: 500);
      await cubit.toggle(first);
      expect((cubit.state as FavoritesLoaded).actionError, isNotNull);

      repository.actionFailure = null;
      await cubit.toggle(first);

      expect((cubit.state as FavoritesLoaded).actionError, isNull);
    });
  });
}
