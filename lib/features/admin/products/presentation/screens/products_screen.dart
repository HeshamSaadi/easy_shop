import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/products_state.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Opens the product details screen and completes with true when the product
/// was edited or deleted there, so the list must reload.
typedef OpenProductDetails = Future<bool?> Function(ProductEntity product);

/// Opens the add-product form and completes with true when a product was saved.
typedef OpenProductForm = Future<bool?> Function();

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({
    super.key,
    required this.onOpenDetails,
    required this.onOpenForm,
    required this.onManageCategories,
    this.showBack = false,
  });

  final OpenProductDetails onOpenDetails;
  final OpenProductForm onOpenForm;
  final VoidCallback onManageCategories;

  /// False when the screen is a bottom-navigation tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProductsCubit>()..load(),
      child: _ProductsView(
        onOpenDetails: onOpenDetails,
        onOpenForm: onOpenForm,
        onManageCategories: onManageCategories,
        showBack: showBack,
      ),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView({
    required this.onOpenDetails,
    required this.onOpenForm,
    required this.onManageCategories,
    required this.showBack,
  });

  final OpenProductDetails onOpenDetails;
  final OpenProductForm onOpenForm;
  final VoidCallback onManageCategories;
  final bool showBack;

  Future<void> _openForm(BuildContext context) async {
    final cubit = context.read<ProductsCubit>();
    final saved = await onOpenForm();
    // The create response has no category, so reload from the server
    if (saved == true) cubit.refresh();
  }

  Future<void> _openDetails(BuildContext context, ProductEntity product) async {
    final cubit = context.read<ProductsCubit>();
    final changed = await onOpenDetails(product);
    if (changed == true) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: ProductsStrings.title,
        showBack: showBack,
        actionIcon: Icons.add,
        onAction: () => _openForm(context),
      ),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listenWhen: (_, current) =>
            current is ProductsLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! ProductsLoaded) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            ProductsInitial() || ProductsLoading() => const AppLoading(),
            ProductsError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<ProductsCubit>().load(),
            ),
            ProductsLoaded(:final products) when products.isEmpty => AppEmpty(
              message: ProductsStrings.empty,
              icon: Icons.inventory_2_outlined,
              actionText: ProductsStrings.addAction,
              onAction: () => _openForm(context),
            ),
            final ProductsLoaded loaded => _LoadedContent(
              state: loaded,
              onOpenDetails: (product) => _openDetails(context, product),
              onManageCategories: onManageCategories,
            ),
          };
        },
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({
    required this.state,
    required this.onOpenDetails,
    required this.onManageCategories,
  });

  final ProductsLoaded state;
  final ValueChanged<ProductEntity> onOpenDetails;
  final VoidCallback onManageCategories;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    final products = state.visibleProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            onChanged: cubit.search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: ProductsStrings.searchHint,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextButton.icon(
              onPressed: onManageCategories,
              icon: const Icon(Icons.category_outlined),
              label: const Text(ProductsStrings.manageCategories),
            ),
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const AppEmpty(
                  message: ProductsStrings.noResults,
                  icon: Icons.search_off,
                )
              : RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: products.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ProductTile(
                        product: product,
                        onTap: () => onOpenDetails(product),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
