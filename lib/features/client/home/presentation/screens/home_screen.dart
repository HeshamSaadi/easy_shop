import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:easy_shop/features/client/favorites/presentation/widgets/product_favorite_button.dart';
import 'package:easy_shop/features/client/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/client/home/presentation/cubit/home_state.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/category_chips.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/category_sheet.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/home_header.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/home_search_field.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs a [HomeCubit] and the shared [FavoritesCubit] above it in the tree
/// (the router and the client shell provide them).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenProduct, this.userName});

  final ValueChanged<String> onOpenProduct;

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return BlocListener<FavoritesCubit, FavoritesState>(
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
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      HomeHeader(userName: userName),
                      const SizedBox(height: AppSpacing.md),
                      HomeSearchField(onChanged: cubit.search),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocConsumer<HomeCubit, HomeState>(
                listenWhen: (_, current) =>
                    current is HomeLoaded && current.refreshError != null,
                listener: (context, state) {
                  if (state is! HomeLoaded) return;
                  final message = state.refreshError;
                  if (message == null) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(message)));
                },
                builder: (context, state) {
                  return switch (state) {
                    HomeInitial() || HomeLoading() => const AppLoading(),
                    HomeError(:final message) => AppError(
                      message: message,
                      onRetry: cubit.load,
                    ),
                    final HomeLoaded loaded => _HomeContent(
                      state: loaded,
                      onOpenProduct: onOpenProduct,
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state, required this.onOpenProduct});

  static const double _maxCardWidth = 220;
  static const double _cardRatio = 0.68;

  final HomeLoaded state;
  final ValueChanged<String> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<HomeCubit>();
    final products = state.visibleProducts;

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.sm,
                    0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        HomeStrings.categories,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (state.categories.isNotEmpty)
                        TextButton(
                          onPressed: () => showCategorySheet(
                            context,
                            categories: state.categories,
                            selectedId: state.selectedCategoryId,
                            onSelected: cubit.selectCategory,
                          ),
                          child: const Text(HomeStrings.seeAll),
                        ),
                    ],
                  ),
                ),
                CategoryChips(
                  categories: state.categories,
                  selectedId: state.selectedCategoryId,
                  onSelected: cubit.selectCategory,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        HomeStrings.products,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        HomeStrings.itemCount(products.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppEmpty(
                message: state.products.isEmpty
                    ? HomeStrings.noProducts
                    : HomeStrings.noResults,
                icon: Icons.inventory_2_outlined,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              sliver: SliverGrid.builder(
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
                    corner: ProductFavoriteButton(
                      product: product,
                      compact: true,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
