import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/theme/app_theme_colors.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/cart/presentation/widgets/quantity_stepper.dart';
import 'package:easy_shop/features/client/products/presentation/constants/product_details_strings.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_cubit.dart';
import 'package:easy_shop/features/client/products/presentation/cubit/product_details_state.dart';
import 'package:easy_shop/features/client/products/presentation/widgets/add_to_cart_bar.dart';
import 'package:easy_shop/features/client/products/presentation/widgets/details_image.dart';
import 'package:easy_shop/features/client/products/presentation/widgets/stock_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs a [ProductDetailsCubit] above it in the tree (the router provides it).
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.onBack,
    required this.onAdded,
  });

  final VoidCallback onBack;

  final VoidCallback onAdded;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
      listenWhen: (previous, current) {
        if (current is! ProductDetailsLoaded) return false;
        final wasAdded =
            previous is ProductDetailsLoaded &&
            previous.status == AddToCartStatus.added;
        final justAdded = current.status == AddToCartStatus.added && !wasAdded;
        return justAdded || current.actionError != null;
      },
      listener: (context, state) {
        if (state is! ProductDetailsLoaded) return;
        if (state.status == AddToCartStatus.added) onAdded();

        final message = state.actionError;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final cubit = context.read<ProductDetailsCubit>();

        return switch (state) {
          ProductDetailsLoading() => _Frame(
            onBack: onBack,
            child: const AppLoading(),
          ),
          ProductDetailsError(:final message) => _Frame(
            onBack: onBack,
            child: AppError(message: message, onRetry: cubit.load),
          ),
          final ProductDetailsLoaded loaded => Scaffold(
            body: _Content(state: loaded, onBack: onBack),
            bottomNavigationBar: AddToCartBar(
              inStock: loaded.product.inStock,
              status: loaded.status,
              onPressed: cubit.addToCart,
            ),
          ),
        };
      },
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: '', showBack: true, onBack: onBack),
      body: child,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state, required this.onBack});

  final ProductDetailsLoaded state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ProductDetailsCubit>();
    final product = state.product;
    final description = product.description;
    final muted = theme.mutedText;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DetailsImage(imageUrl: product.imageUrl, onBack: onBack),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.categoryName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(product.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ProductDetailsStrings.money(product.price),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: AppSizes.iconSm,
                    color: muted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      ProductDetailsStrings.soldBy(product.storeName),
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  ProductDetailsStrings.description,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: StockBox(stock: product.stock)),
                  if (product.inStock) ...[
                    const SizedBox(width: AppSpacing.lg),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ProductDetailsStrings.quantity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        QuantityStepper(
                          quantity: state.quantity,
                          maxQuantity: product.stock,
                          isBusy: state.status == AddToCartStatus.adding,
                          onIncrease: cubit.increase,
                          onDecrease: cubit.decrease,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
