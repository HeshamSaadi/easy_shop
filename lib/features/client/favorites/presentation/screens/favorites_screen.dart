import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_pull_to_refresh.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/favorites/presentation/constants/favorites_strings.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:easy_shop/features/client/favorites/presentation/widgets/favorite_heart_button.dart';
import 'package:easy_shop/features/client/favorites/presentation/widgets/favorites_empty.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs a [FavoritesCubit] above it in the tree (the client shell provides
/// it, because the heart on the product details screen uses the same list).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.cardBuilder});

  /// Builds one card. The router supplies it, so this feature does not import
  /// the Home screen's card. [heart] goes in the card's corner.
  final Widget Function(ProductEntity product, Widget heart) cardBuilder;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();

    return Scaffold(
      appBar: const AppTopBar(title: FavoritesStrings.title, showBack: false),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          return switch (state) {
            FavoritesInitial() || FavoritesLoading() => const AppLoading(),
            FavoritesError(:final message) => AppError(
              message: message,
              onRetry: cubit.load,
            ),
            FavoritesLoaded(:final products) when products.isEmpty =>
              AppPullToRefresh(
                onRefresh: cubit.refresh,
                child: const FavoritesEmpty(),
              ),
            final FavoritesLoaded loaded => _FavoritesGrid(
              state: loaded,
              cardBuilder: cardBuilder,
            ),
          };
        },
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.state, required this.cardBuilder});

  static const double _maxCardWidth = 220;
  static const double _cardRatio = 0.68;

  final FavoritesLoaded state;
  final Widget Function(ProductEntity product, Widget heart) cardBuilder;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();
    final products = state.products;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _maxCardWidth,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: _cardRatio,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) {
          final product = products[index];
          return cardBuilder(
            product,
            FavoriteHeartButton(
              compact: true,
              isFavorite: true,
              isBusy: state.isBusy(product.id),
              onPressed: () => cubit.toggle(product),
            ),
          );
        },
      ),
    );
  }
}
