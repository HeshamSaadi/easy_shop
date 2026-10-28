import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/orders/presentation/constants/orders_strings.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_cubit.dart';
import 'package:easy_shop/features/admin/orders/presentation/cubit/order_details_state.dart';
import 'package:easy_shop/features/admin/orders/presentation/widgets/order_details_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Shows one order. Read-only: the API has no endpoint to change the status.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<OrderDetailsCubit>(param1: code)..load(),
      child: const _OrderDetailsView(),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: OrdersStrings.detailsTitle,
        showBack: true,
      ),
      body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
        builder: (context, state) {
          return switch (state) {
            OrderDetailsInitial() ||
            OrderDetailsLoading() => const AppLoading(),
            OrderDetailsError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<OrderDetailsCubit>().load(),
            ),
            OrderDetailsLoaded(:final order) => OrderDetailsBody(order: order),
          };
        },
      ),
    );
  }
}
