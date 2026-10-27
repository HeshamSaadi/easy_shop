import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/admin/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onAddProduct,
    required this.onManageCategories,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onManageCategories;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add),
            label: const Text(HomeStrings.addProduct),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManageCategories,
            icon: const Icon(Icons.category_outlined),
            label: const Text(HomeStrings.manageCategories),
          ),
        ),
      ],
    );
  }
}
