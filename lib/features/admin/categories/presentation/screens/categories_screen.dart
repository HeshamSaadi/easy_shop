import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/confirm_delete_dialog.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_state.dart';
import 'package:easy_shop/features/admin/categories/presentation/screens/category_form_screen.dart';
import 'package:easy_shop/features/admin/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, this.showBack = false});

  /// False when the screen is a bottom-navigation tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CategoriesCubit>()..load(),
      child: _CategoriesView(showBack: showBack),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView({required this.showBack});

  final bool showBack;

  Future<void> _openForm(
    BuildContext context, {
    CategoryEntity? category,
  }) async {
    final cubit = context.read<CategoriesCubit>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormScreen(category: category)),
    );
    // The slug changes when the name changes, so reload from the server
    if (saved == true) cubit.refresh();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CategoryEntity category,
  ) async {
    final cubit = context.read<CategoriesCubit>();
    final confirmed = await showConfirmDeleteDialog(
      context,
      title: 'Delete category?',
      message:
          '"${category.name}" is shared with all admins and will be deleted for everyone.',
    );
    if (confirmed) cubit.delete(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Categories',
        showBack: showBack,
        actionIcon: Icons.add,
        onAction: () => _openForm(context),
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listenWhen: (_, current) =>
            current is CategoriesLoaded && current.actionError != null,
        listener: (context, state) {
          final message = (state as CategoriesLoaded).actionError!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return switch (state) {
            CategoriesInitial() || CategoriesLoading() => const AppLoading(),
            CategoriesError(:final message) => AppError(
              message: message,
              onRetry: () => context.read<CategoriesCubit>().load(),
            ),
            CategoriesLoaded(:final categories) when categories.isEmpty =>
              AppEmpty(
                message: 'No categories yet',
                icon: Icons.category_outlined,
                actionText: 'Add category',
                onAction: () => _openForm(context),
              ),
            CategoriesLoaded(:final categories) => RefreshIndicator(
              onRefresh: () => context.read<CategoriesCubit>().refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: categories.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return CategoryTile(
                    category: category,
                    onEdit: () => _openForm(context, category: category),
                    onDelete: () => _confirmDelete(context, category),
                  );
                },
              ),
            ),
          };
        },
      ),
    );
  }
}
