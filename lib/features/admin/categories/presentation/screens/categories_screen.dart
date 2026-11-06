import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:easy_shop/core/widgets/app_empty.dart';
import 'package:easy_shop/core/widgets/app_error.dart';
import 'package:easy_shop/core/widgets/app_loading.dart';
import 'package:easy_shop/core/widgets/app_top_bar.dart';
import 'package:easy_shop/core/widgets/confirm_delete_dialog.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/presentation/constants/categories_strings.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_state.dart';
import 'package:easy_shop/features/admin/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Opens the add/edit form ([category] is null to add) and completes with
/// true when something was saved.
typedef OpenCategoryForm = Future<bool?> Function(CategoryEntity? category);

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({
    super.key,
    required this.onOpenForm,
    this.showBack = false,
  });

  final OpenCategoryForm onOpenForm;

  /// False when the screen is a bottom-navigation tab.
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<CategoriesCubit>()..load(),
      child: _CategoriesView(onOpenForm: onOpenForm, showBack: showBack),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView({required this.onOpenForm, required this.showBack});

  final OpenCategoryForm onOpenForm;
  final bool showBack;

  Future<void> _openForm(
    BuildContext context, {
    CategoryEntity? category,
  }) async {
    final cubit = context.read<CategoriesCubit>();
    final saved = await onOpenForm(category);
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
      title: CategoriesStrings.deleteTitle,
      message: CategoriesStrings.deleteMessage(category.name),
    );
    if (confirmed) cubit.delete(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: CategoriesStrings.title,
        showBack: showBack,
        actionIcon: Icons.add,
        onAction: () => _openForm(context),
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listenWhen: (_, current) =>
            current is CategoriesLoaded && current.actionError != null,
        listener: (context, state) {
          if (state is! CategoriesLoaded) return;
          final message = state.actionError;
          if (message == null) return;
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
                message: CategoriesStrings.empty,
                icon: Icons.category_outlined,
                actionText: CategoriesStrings.addAction,
                onAction: () => _openForm(context),
              ),
            CategoriesLoaded(:final categories, :final deletingId) =>
              RefreshIndicator(
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
                      isDeleting: deletingId == category.id,
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
