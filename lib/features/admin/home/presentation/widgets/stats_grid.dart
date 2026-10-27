import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';

/// The four dashboard numbers in a 2x2 grid.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsRow(
          first: StatCard(
            icon: Icons.inventory_2_outlined,
            label: HomeStrings.totalProducts,
            count: stats.productsCount,
          ),
          second: StatCard(
            icon: Icons.receipt_long_outlined,
            label: HomeStrings.totalOrders,
            count: stats.ordersCount,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _StatsRow(
          first: StatCard(
            icon: Icons.hourglass_empty,
            label: HomeStrings.pendingOrders,
            count: stats.pendingOrdersCount,
          ),
          second: StatCard(
            icon: Icons.category_outlined,
            label: HomeStrings.categories,
            count: stats.categoriesCount,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight keeps both cards the same height if a label wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: second),
        ],
      ),
    );
  }
}
