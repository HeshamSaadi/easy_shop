import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/app_pull_to_refresh.dart';
import 'package:easy_shop/core/widgets/confirm_delete_dialog.dart';
import 'package:easy_shop/features/client/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop/features/client/cart/presentation/constants/cart_strings.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop/features/client/cart/presentation/cubit/cart_state.dart';
import 'package:easy_shop/features/client/cart/presentation/widgets/cart_item_tile.dart';
import 'package:easy_shop/features/client/cart/presentation/widgets/cart_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs a [CartCubit] above it in the tree (the client shell provides it,
/// because the Cart tab badge uses the same cart).
class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.onCheckout,
    required this.onStartShopping,
  });

  final VoidCallback onCheckout;
  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: CartStrings.title, showBack: false),
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (_, current) =>
            current is CartLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! CartLoaded) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            CartInitial() || CartLoading() => const AppLoading(),
            CartError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<CartCubit>().load(),
            ),
            CartLoaded(:final items) when items.isEmpty => AppPullToRefresh(
              onRefresh: () => context.read<CartCubit>().refresh(),
              child: AppEmpty(
                message: CartStrings.empty,
                icon: Icons.shopping_cart_outlined,
                actionText: CartStrings.startShopping,
                onAction: onStartShopping,
              ),
            ),
            final CartLoaded loaded => _CartContent(
              state: loaded,
              onCheckout: onCheckout,
            ),
          };
        },
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.state, required this.onCheckout});

  final CartLoaded state;
  final VoidCallback onCheckout;

  /// Minus at quantity 1 removes the item, so it asks first.
  Future<void> _decrease(BuildContext context, CartItemEntity item) async {
    if (item.quantity > 1) {
      await context.read<CartCubit>().decrease(item);
      return;
    }
    await _confirmRemove(context, item);
  }

  Future<void> _confirmRemove(BuildContext context, CartItemEntity item) async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: CartStrings.removeTitle,
      message: CartStrings.removeMessage(item.product.name),
      confirmText: CartStrings.removeConfirm,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<CartCubit>().remove(item.product.id);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final items = state.items;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, index) {
                final item = items[index];
                return CartItemTile(
                  item: item,
                  isBusy: state.isBusy(item.product.id),
                  onIncrease: () => cubit.increase(item),
                  onDecrease: () => _decrease(context, item),
                  onRemove: () => _confirmRemove(context, item),
                );
              },
            ),
          ),
        ),
        CartSummary(
          itemCount: items.length,
          total: state.total,
          hasProblems: state.hasProblems,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}
