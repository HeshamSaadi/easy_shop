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
import 'package:easy_shop/features/client/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs a [FavoritesCubit] above it in the tree (the client shell provides
/// it, because the heart on the product details screen uses the same list).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.onOpenProduct});

  final ValueChanged<String> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FavoritesCubit>();

    return Scaffold(
      appBar: const AppTopBar(title: FavoritesStrings.title, showBack: false),
      body: BlocConsumer<FavoritesCubit, FavoritesState>(
        listenWhen: (_, current) =>
            current is FavoritesLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! FavoritesLoaded) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
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
              onOpenProduct: onOpenProduct,
            ),
          };
        },
      ),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.state, required this.onOpenProduct});

  static const double _maxCardWidth = 220;
  static const double _cardRatio = 0.68;

  final FavoritesLoaded state;
  final ValueChanged<String> onOpenProduct;

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
          return ProductCard(
            product: product,
            onTap: () => onOpenProduct(product.slug),
            corner: FavoriteHeartButton(
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
