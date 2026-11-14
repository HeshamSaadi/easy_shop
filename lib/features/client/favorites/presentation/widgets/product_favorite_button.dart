import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:easy_shop/features/client/favorites/presentation/cubit/favorites_state.dart';
import 'package:easy_shop/features/client/favorites/presentation/widgets/favorite_heart_button.dart';
import 'package:easy_shop/features/client/products/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The heart of one product, tied to the shared [FavoritesCubit]. Used on
/// the product cards. Needs the cubit above it in the tree.
class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    super.key,
    required this.product,
    this.compact = false,
  });

  final ProductEntity product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final loaded = state is FavoritesLoaded ? state : null;

        return FavoriteHeartButton(
          compact: compact,
          isFavorite: loaded?.isFavorite(product.id) ?? false,
          isBusy: loaded?.isBusy(product.id) ?? false,
          onPressed: () => context.read<FavoritesCubit>().toggle(product),
        );
      },
    );
  }
}
