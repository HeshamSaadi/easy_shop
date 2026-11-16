import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/add_favorite.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/get_favorites.dart';
import 'package:easy_shop/features/client/favorites/domain/usecases/remove_favorite.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required this._getFavorites,
    required this._addFavorite,
    required this._removeFavorite,
  }) : super(const FavoritesInitial());

  static const int _alreadyFavoriteStatus = 400;

  final GetFavorites _getFavorites;
  final AddFavorite _addFavorite;
  final RemoveFavorite _removeFavorite;

  Future<void> load() async {
    emit(const FavoritesLoading());
    final result = await _getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (products) => emit(FavoritesLoaded(products)),
    );
  }

  Future<void> refresh() async {
    final result = await _getFavorites();
    result.fold(_keepListWithError, _replaceProducts);
  }

  Future<void> toggle(ProductEntity product) async {
    final current = state;
    if (current is FavoritesLoading) return;
    if (current is! FavoritesLoaded) {
      await load();
      return;
    }
    if (current.isBusy(product.id)) return;

    final wasFavorite = current.isFavorite(product.id);
    emit(
      current.copyWith(busyProductIds: {...current.busyProductIds, product.id}),
    );

    final result = wasFavorite
        ? await _removeFavorite(product.id)
        : await _addFavorite(product.id);

    final failure = result.fold<Failure?>((f) => f, (_) => null);
    if (failure != null && failure.statusCode != _alreadyFavoriteStatus) {
      _finish(product.id, error: failure.message);
      return;
    }

    // `store` and `destroy` return no list, so the list is fetched again.
    final favorites = await _getFavorites();
    favorites.fold(
      (f) => _finish(product.id, error: f.message),
      (products) => _finish(product.id, products: products),
    );
  }

  void _finish(int productId, {List<ProductEntity>? products, String? error}) {
    final current = state;
    if (current is! FavoritesLoaded) return;
    emit(
      current.copyWith(
        products: products,
        busyProductIds: {...current.busyProductIds}..remove(productId),
        actionError: error,
      ),
    );
  }

  void _replaceProducts(List<ProductEntity> products) {
    final current = state;
    final busy = current is FavoritesLoaded ? current.busyProductIds : <int>{};
    emit(FavoritesLoaded(products, busyProductIds: busy));
  }

  void _keepListWithError(Failure failure) {
    final current = state;
    if (current is FavoritesLoaded) {
      emit(current.copyWith(actionError: failure.message));
    } else {
      emit(FavoritesError(failure.message));
    }
  }
}
