import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/home/presentation/constants/home_strings.dart';
import 'package:flutter/material.dart';

const double _maxHeightFactor = 0.85;
Future<void> showCategorySheet(
  BuildContext context, {
  required List<CategoryEntity> categories,
  required int? selectedId,
  required ValueChanged<int?> onSelected,
}) {
  final sorted = [...categories]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
    ),
    builder: (sheetContext) {
      void pick(int? id) {
        Navigator.of(sheetContext).pop();
        onSelected(id);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Text(
              HomeStrings.categories,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              children: [
                _CategoryTile(
                  label: HomeStrings.allCategories,
                  icon: Icons.apps_outlined,
                  isSelected: selectedId == null,
                  onTap: () => pick(null),
                ),
                for (final category in sorted)
                  _CategoryTile(
                    label: category.name,
                    icon: Icons.category_outlined,
                    isSelected: category.id == selectedId,
                    onTap: () => pick(category.id),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      leading: Icon(icon),
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, size: AppSizes.iconMd)
          : null,
      onTap: onTap,
    );
  }
}
