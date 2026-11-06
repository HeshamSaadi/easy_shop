import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/orders/domain/entities/order_entity.dart';
import 'package:easy_shop/features/admin/orders/presentation/constants/orders_strings.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/orders_state.dart';
import 'package:easy_shop/features/admin/orders/presentation/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, required this.onOpenDetails});

  /// Opens the details screen of [order].
  final ValueChanged<OrderEntity> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrdersCubit>()..load(),
      child: _OrdersView(onOpenDetails: onOpenDetails),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView({required this.onOpenDetails});

  final ValueChanged<OrderEntity> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: OrdersStrings.title, showBack: false),
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
              onRetry: () => context.read<OrdersCubit>().load(),
            ),
            OrdersLoaded(:final orders) when orders.isEmpty => const AppEmpty(
              message: OrdersStrings.empty,
              icon: Icons.receipt_long_outlined,
            ),
            OrdersLoaded(:final orders) => RefreshIndicator(
              onRefresh: () => context.read<OrdersCubit>().refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: orders.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return OrderTile(
                    order: order,
                    onTap: () => onOpenDetails(order),
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
