import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_pull_to_refresh.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/orders/presentation/constants/client_orders_strings.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/orders_state.dart';
import 'package:easy_shop/features/client/orders/presentation/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs an [OrdersCubit] above it in the tree (the client shell provides
/// it, so the list can be refreshed after an order is placed).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({
    super.key,
    required this.onOpenOrder,
    required this.onStartShopping,
  });

  /// Receives the order code.
  final ValueChanged<String> onOpenOrder;
  final VoidCallback onStartShopping;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrdersCubit>();

    return Scaffold(
      appBar: const AppTopBar(
        title: ClientOrdersStrings.title,
        showBack: false,
      ),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listenWhen: (_, current) =>
            current is OrdersLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! OrdersLoaded) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            OrdersInitial() || OrdersLoading() => const AppLoading(),
            OrdersError(:final message) => AppError(
              message: message,
              onRetry: cubit.load,
            ),
            OrdersLoaded(:final orders) when orders.isEmpty => AppPullToRefresh(
              onRefresh: cubit.refresh,
              child: AppEmpty(
                message: ClientOrdersStrings.empty,
                icon: Icons.receipt_long_outlined,
                actionText: ClientOrdersStrings.startShopping,
                onAction: onStartShopping,
              ),
            ),
            OrdersLoaded(:final orders) => RefreshIndicator(
              onRefresh: cubit.refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: orders.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return OrderTile(
                    order: order,
                    onTap: () => onOpenOrder(order.code),
                  );
                },
              ),
            ),
          };
        },
      ),
    );
  }
}
