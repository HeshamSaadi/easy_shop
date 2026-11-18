import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/client/orders/presentation/constants/client_orders_strings.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/order_details_cubit.dart';
import 'package:easy_shop/features/client/orders/presentation/cubit/order_details_state.dart';
import 'package:easy_shop/features/client/orders/presentation/widgets/order_details_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Needs an [OrderDetailsCubit] above it in the tree (the router provides
/// it).
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderDetailsCubit>();

    return Scaffold(
      appBar: AppTopBar(
        title: ClientOrdersStrings.detailsTitle,
        showBack: true,
        onBack: onBack,
      ),
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          return switch (state) {
            OrderDetailsInitial() ||
            OrderDetailsLoading() => const AppLoading(),
            OrderDetailsError(:final message) => AppError(
              message: message,
              onRetry: cubit.load,
            ),
            OrderDetailsLoaded(:final order) => OrderDetailsBody(order: order),
          };
        },
      ),
    );
  }
}
