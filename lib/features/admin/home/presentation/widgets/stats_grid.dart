import 'package:easy_shop/core/theme/app_colors.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/features/admin/home/domain/entities/dashboard_stats.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/admin/home/presentation/widgets/stat_card.dart';
import 'package:flutter/material.dart';

/// The four dashboard numbers in a 2x2 grid, inside one card.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: AppSpacing.md,
      child: Column(
        children: [
          _StatsRow(
            first: StatCard(
              icon: Icons.view_in_ar_outlined,
              label: HomeStrings.totalProducts,
              count: stats.productsCount,
              color: AppColors.error,
              background: isDark
                  ? AppColors.darkErrorBackground
                  : AppColors.primarySoft,
            ),
            second: StatCard(
              icon: Icons.shopping_bag_outlined,
              label: HomeStrings.totalOrders,
              count: stats.ordersCount,
              color: AppColors.info,
              background: isDark
                  ? AppColors.darkInfoBackground
                  : AppColors.infoBackground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatsRow(
            first: StatCard(
              icon: Icons.schedule,
              label: HomeStrings.pendingOrders,
              count: stats.pendingOrdersCount,
              color: AppColors.warning,
              background: isDark
                  ? AppColors.darkWarningBackground
                  : AppColors.warningBackground,
            ),
            second: StatCard(
              icon: Icons.sell_outlined,
              label: HomeStrings.categories,
              count: stats.categoriesCount,
              color: AppColors.success,
              background: isDark
                  ? AppColors.darkSuccessBackground
                  : AppColors.successBackground,
            ),
          ),
        ],
      ),
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
