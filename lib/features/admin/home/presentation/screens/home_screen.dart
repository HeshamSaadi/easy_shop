import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_state.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<HomeCubit>()..load(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: HomeStrings.title, showBack: false),
      body: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (_, current) =>
            current is HomeLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! HomeLoaded) return;
          final message = state.actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            HomeInitial() || HomeLoading() => const AppLoading(),
            HomeError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<HomeCubit>().load(),
            ),
            HomeLoaded(:final stats) => RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  StatCard(
                    icon: Icons.category_outlined,
                    label: HomeStrings.categories,
                    count: stats.categoriesCount,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: HomeStrings.products,
                    count: stats.productsCount,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  StatCard(
                    icon: Icons.receipt_long_outlined,
                    label: HomeStrings.orders,
                    count: stats.ordersCount,
                  ),
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
