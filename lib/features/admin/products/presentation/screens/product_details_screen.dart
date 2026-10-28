import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/confirm_delete_dialog.dart';
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

/// Shows one product. Closes with true when the product was edited or
/// deleted, so the list can reload (a rename also changes the slug).
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

  static const double _overlayAlpha = 0.6;

  Future<void> _edit(BuildContext context, ProductEntity product) async {
    final navigator = Navigator.of(context);
    final saved = await onEdit(product);
    if (saved == true) navigator.pop(true);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ProductEntity product,
  ) async {
    final cubit = context.read<ProductDetailsCubit>();
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: ProductsStrings.deleteTitle,
      message: ProductsStrings.deleteMessage(product.name),
    );
    if (confirmed) cubit.delete();
  }

  void _onStateChanged(BuildContext context, ProductDetailsState state) {
    if (state is ProductDetailsDeleted) {
      Navigator.of(context).pop(true);
      return;
    }
    if (state is! ProductDetailsLoaded) return;
    final message = state.actionError;
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
      listenWhen: (_, current) =>
          current is ProductDetailsDeleted ||
          (current is ProductDetailsLoaded && current.actionError != null),
      listener: _onStateChanged,
      builder: (context, state) {
        final loaded = state is ProductDetailsLoaded ? state : null;
        final isDeleting = loaded?.isDeleting ?? false;

        return PopScope(
          // Closing the screen mid-delete would leave the list out of date
          canPop: !isDeleting,
          child: Scaffold(
            appBar: AppTopBar(
              title: ProductsStrings.detailsTitle,
              showBack: true,
              actionIcon: loaded == null ? null : Icons.delete_outline,
              onAction: loaded == null
                  ? null
                  : () => _confirmDelete(context, loaded.product),
            ),
            body: switch (state) {
              ProductDetailsInitial() ||
              ProductDetailsLoading() ||
              ProductDetailsDeleted() => const AppLoading(),
              ProductDetailsError(:final message) => AppError(
                message: message,
                onRetry: () => context.read<ProductDetailsCubit>().load(),
              ),
              ProductDetailsLoaded(:final product) => Stack(
                children: [
                  ProductDetailsBody(
                    product: product,
                    onEdit: () => _edit(context, product),
                  ),
                  if (isDeleting)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Theme.of(context).colorScheme.surface
                            .withValues(alpha: _overlayAlpha),
                        child: const AppLoading(),
                      ),
                    ),
                ],
              ),
            },
          ),
        );
      },
    );
  }
}
