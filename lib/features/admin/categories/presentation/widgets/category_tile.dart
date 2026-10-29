import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_card.dart';
import 'package:easy_shop/core/widgets/app_icon_badge.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/presentation/constants/categories_strings.dart';
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
  });

  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = category.description;

    return AppCard(
      child: Row(
        children: [
          const AppIconBadge(icon: Icons.sell_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: theme.textTheme.titleMedium),
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: CategoriesStrings.editTooltip,
            onPressed: isDeleting ? null : onEdit,
            icon: Icon(
              Icons.edit_outlined,
              size: AppSizes.iconLg,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            tooltip: CategoriesStrings.deleteTooltip,
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox.square(
                    dimension: AppSizes.loaderSm,
                    child: CircularProgressIndicator(
                      strokeWidth: AppSizes.loaderStroke,
                    ),
                  )
                : Icon(
                    Icons.delete_outline,
                    size: AppSizes.iconLg,
                    color: theme.colorScheme.error,
                  ),
          ),
        ],
      ),
    );
  }
}
