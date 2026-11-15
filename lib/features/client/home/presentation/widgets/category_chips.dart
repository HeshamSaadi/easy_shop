import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/home/presentation/constants/home_strings.dart';
import 'package:easy_shop/features/client/home/presentation/widgets/category_chip.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  static const double _height = 44;

  final List<CategoryEntity> categories;

  /// `null` means the "All" chip is selected.
  final int? selectedId;

  /// Called with the category id, or `null` for "All".
  final ValueChanged<int?> onSelected;

  List<CategoryEntity> get _ordered {
    return [
      ...categories.where((category) => category.id == selectedId),
      ...categories.where((category) => category.id != selectedId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ordered = _ordered;

    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: ordered.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final category = index == 0 ? null : ordered[index - 1];

          return CategoryChip(
            label: category?.name ?? HomeStrings.allCategories,
            isSelected: category?.id == selectedId,
            onTap: () => onSelected(category?.id),
          );
        },
      ),
    );
  }
}
