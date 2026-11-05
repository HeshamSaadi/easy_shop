import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/add_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/delete_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/update_category.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/categories_state.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_cubit.dart';
import 'package:easy_shop/features/admin/categories/presentation/cubit/category_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_category_repository.dart';

const _shoes = CategoryEntity(id: 1, name: 'Shoes', slug: 'shoes');
const _bags = CategoryEntity(id: 2, name: 'Bags', slug: 'bags');

/// Holds the "add" request open until [gate] completes, to test double taps.
class _PausedCategoryRepository extends FakeCategoryRepository {
  final Completer<void> gate = Completer<void>();

  @override
  Future<Either<Failure, Unit>> addCategory({
    required String name,
    String? description,
  }) async {
    await gate.future;
    return super.addCategory(name: name, description: description);
  }
}

/// Runs [action] and returns every state the cubit emitted meanwhile.
Future<List<S>> _collect<S>(
  Cubit<S> cubit,
  Future<void> Function() action,
) async {
  final states = <S>[];
  final subscription = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await subscription.cancel();
  return states;
}

void main() {
  late FakeCategoryRepository repository;

  setUp(() => repository = FakeCategoryRepository());

  group('CategoriesCubit', () {
    CategoriesCubit buildCubit() => CategoriesCubit(
      getCategories: GetCategories(repository),
      deleteCategory: DeleteCategory(repository),
    );

    test('starts as initial', () {
      expect(buildCubit().state, isA<CategoriesInitial>());
    });

    test('load emits loading then loaded', () async {
      repository.getResult = const Right<Failure, List<CategoryEntity>>([
        _shoes,
      ]);
      final cubit = buildCubit();

      final states = await _collect(cubit, cubit.load);

      expect(states[0], isA<CategoriesLoading>());
      expect(states[1], isA<CategoriesLoaded>());
      expect((states[1] as CategoriesLoaded).categories, [_shoes]);
    });

    test('load emits error when the request fails', () async {
      repository.getResult = const Left<Failure, List<CategoryEntity>>(
        Failure('No internet'),
      );
      final cubit = buildCubit();

      final states = await _collect(cubit, cubit.load);

      expect(states.last, isA<CategoriesError>());
      expect((states.last as CategoriesError).message, 'No internet');
    });

    test('refresh keeps the old list when it fails', () async {
      repository.getResult = const Right<Failure, List<CategoryEntity>>([
        _shoes,
      ]);
      final cubit = buildCubit();
      await cubit.load();

      repository.getResult = const Left<Failure, List<CategoryEntity>>(
        Failure('Timeout'),
      );
      final states = await _collect(cubit, cubit.refresh);

      final state = states.single as CategoriesLoaded;
      expect(state.categories, [_shoes]);
      expect(state.actionError, 'Timeout');
    });

    test('refresh emits error when there is no list yet', () async {
      repository.getResult = const Left<Failure, List<CategoryEntity>>(
        Failure('Timeout'),
      );
      final cubit = buildCubit();

      final states = await _collect(cubit, cubit.refresh);

      expect(states.single, isA<CategoriesError>());
    });

    test('delete marks the item, then removes it', () async {
      repository.getResult = const Right<Failure, List<CategoryEntity>>([
        _shoes,
        _bags,
      ]);
      final cubit = buildCubit();
      await cubit.load();

      final states = await _collect(cubit, () => cubit.delete(_shoes));

      expect((states[0] as CategoriesLoaded).deletingId, _shoes.id);
      final last = states.last as CategoriesLoaded;
      expect(last.deletingId, isNull);
      expect(last.categories.map((c) => c.id), [_bags.id]);
      expect(repository.calls, contains('delete:shoes'));
    });

    test('delete failure keeps the list and sets actionError', () async {
      repository.getResult = const Right<Failure, List<CategoryEntity>>([
        _shoes,
      ]);
      final cubit = buildCubit();
      await cubit.load();
      repository.actionResult = const Left<Failure, Unit>(
        Failure('Category has products'),
      );

      final states = await _collect(cubit, () => cubit.delete(_shoes));

      final last = states.last as CategoriesLoaded;
      expect(last.categories, [_shoes]);
      expect(last.actionError, 'Category has products');
      expect(last.deletingId, isNull);
    });

    test('delete does nothing before the list is loaded', () async {
      final cubit = buildCubit();

      final states = await _collect(cubit, () => cubit.delete(_shoes));

      expect(states, isEmpty);
      expect(repository.calls, isEmpty);
    });
  });

  group('CategoryFormCubit', () {
    CategoryFormCubit buildCubit() => CategoryFormCubit(
      addCategory: AddCategory(repository),
      updateCategory: UpdateCategory(repository),
    );

    test('starts idle', () {
      expect(buildCubit().state, isA<CategoryFormIdle>());
    });

    test('submit without slug adds a category', () async {
      final cubit = buildCubit();

      final states = await _collect(cubit, () => cubit.submit(name: 'Shoes'));

      expect(states[0], isA<CategoryFormSubmitting>());
      expect(states[1], isA<CategoryFormSuccess>());
      expect(repository.calls, ['add:Shoes:']);
    });

    test('submit with slug updates the category', () async {
      final cubit = buildCubit();

      await cubit.submit(slug: 'shoes', name: 'Sneakers', description: 'New');

      expect(repository.calls, ['update:shoes:Sneakers:New']);
      expect(cubit.state, isA<CategoryFormSuccess>());
    });

    test('submit failure emits the failure message', () async {
      repository.actionResult = const Left<Failure, Unit>(
        Failure('Name is taken'),
      );
      final cubit = buildCubit();

      final states = await _collect(cubit, () => cubit.submit(name: 'Shoes'));

      expect(states.last, isA<CategoryFormFailure>());
      expect((states.last as CategoryFormFailure).message, 'Name is taken');
    });

    test(
      'submit ignores a second tap while the first one is running',
      () async {
        final paused = _PausedCategoryRepository();
        final cubit = CategoryFormCubit(
          addCategory: AddCategory(paused),
          updateCategory: UpdateCategory(paused),
        );

        final first = cubit.submit(name: 'Shoes');
        await cubit.submit(name: 'Shoes'); // ignored: state is Submitting
        paused.gate.complete();
        await first;

        expect(paused.calls, ['add:Shoes:']);
        expect(cubit.state, isA<CategoryFormSuccess>());
      },
    );
  });
}
