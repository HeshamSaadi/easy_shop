import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_state.dart';
import 'package:easy_shop/features/admin/products/presentation/widgets/product_details_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Opens the edit form for [product] and completes with true when it was saved.
typedef OpenProductEditForm = Future<bool?> Function(ProductEntity product);

/// Shows one product. Closes with true when the product was edited, so the
/// list can reload (a rename also changes the slug).
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.slug,
    required this.onEdit,
  });

  final String slug;
  final OpenProductEditForm onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProductDetailsCubit>(param1: slug)..load(),
      child: _ProductDetailsView(onEdit: onEdit),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView({required this.onEdit});

  final OpenProductEditForm onEdit;

  Future<void> _edit(BuildContext context, ProductEntity product) async {
    final navigator = Navigator.of(context);
    final saved = await onEdit(product);
    if (saved == true) navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: ProductsStrings.detailsTitle,
        showBack: true,
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          return switch (state) {
            ProductDetailsInitial() ||
            ProductDetailsLoading() => const AppLoading(),
            ProductDetailsError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<ProductDetailsCubit>().load(),
            ),
            ProductDetailsLoaded(:final product) => ProductDetailsBody(
              product: product,
              onEdit: () => _edit(context, product),
            ),
          };
        },
      ),
    );
  }
}
