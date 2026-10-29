import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/utils/price_formatter.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_icon_badge.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_network_image.dart';
import 'package:easy_shop/core/widgets/app_status_label.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_cubit.dart';
import 'package:easy_shop/features/admin/home/presentation/cubit/home_state.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/greeting_header.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/home_list_item.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/home_section.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/quick_actions.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Opens another screen. The home reloads when it comes back, because the
/// user may have added a product or changed a category there.
typedef HomeNavigation = Future<Object?> Function();

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onAddProduct,
    required this.onManageCategories,
    required this.onSeeAllOrders,
    required this.onSeeAllProducts,
    this.adminName,
    this.storeName,
  });

  final HomeNavigation onAddProduct;
  final HomeNavigation onManageCategories;
  final VoidCallback onSeeAllOrders;
  final VoidCallback onSeeAllProducts;

  /// Come from the admin profile (A11). The greeting hides them while null.
  final String? adminName;
  final String? storeName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<HomeCubit>()..load(),
      child: _HomeView(screen: this),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({required this.screen});

  final HomeScreen screen;

  Future<void> _open(BuildContext context, HomeNavigation open) async {
    final cubit = context.read<HomeCubit>();
    await open();
    cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            HomeInitial() ||
            HomeLoading() => const SafeArea(child: AppLoading()),
            HomeError(:final message) => SafeArea(
              child: AppError(
                message: message,
                onRetry: () => context.read<HomeCubit>().load(),
              ),
            ),
            // The header is orange, so the status bar icons must be light
            HomeLoaded(:final stats) => AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: RefreshIndicator(
                edgeOffset: MediaQuery.paddingOf(context).top,
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: _LoadedContent(
                  stats: stats,
                  screen: screen,
                  onOpen: (open) => _open(context, open),
                ),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  const _LoadedContent({
    required this.stats,
    required this.screen,
    required this.onOpen,
  });

  final DashboardStats stats;
  final HomeScreen screen;
  final ValueChanged<HomeNavigation> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        Stack(
          children: [
            GreetingHeader(
              adminName: screen.adminName,
              storeName: screen.storeName,
            ),
            Padding(
              padding: const EdgeInsets.only(top: GreetingHeader.contentTop),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatsGrid(stats: stats),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      HomeStrings.quickActions,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    QuickActions(
                      onAddProduct: () => onOpen(screen.onAddProduct),
                      onManageCategories: () =>
                          onOpen(screen.onManageCategories),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    HomeSection(
                      title: HomeStrings.recentOrders,
                      emptyText: HomeStrings.noOrders,
                      onSeeAll: screen.onSeeAllOrders,
                      children: [
                        for (final order in stats.recentOrders)
                          HomeListItem(
                            leading: const AppIconBadge(
                              icon: Icons.shopping_bag_outlined,
                            ),
                            title: '#${order.code}',
                            subtitle: order.client.name,
                            trailingText: PriceFormatter.format(
                              order.totalPrice,
                            ),
                            label: AppStatusLabel(
                              text: _capitalize(order.status),
                              color: order.isPending ? AppColors.warning : null,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    HomeSection(
                      title: HomeStrings.productsOverview,
                      emptyText: HomeStrings.noProducts,
                      onSeeAll: screen.onSeeAllProducts,
                      children: [
                        for (final product in stats.overviewProducts)
                          HomeListItem(
                            leading: SizedBox.square(
                              dimension: AppIconBadge.size,
                              child: AppNetworkImage(url: product.imageUrl),
                            ),
                            title: product.name,
                            subtitle:
                                '${PriceFormatter.format(product.price)}  ·  '
                                '${HomeStrings.quantity(product.quantity)}',
                            label: AppStatusLabel(
                              text: product.isVisible
                                  ? HomeStrings.visible
                                  : HomeStrings.hidden,
                              color: product.isVisible
                                  ? AppColors.success
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
