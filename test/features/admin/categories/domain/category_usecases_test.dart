import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/add_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/delete_category.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/get_categories.dart';
import 'package:easy_shop/features/admin/categories/domain/usecases/update_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_category_repository.dart';

void main() {
  late FakeCategoryRepository repository;

  setUp(() => repository = FakeCategoryRepository());

  group('GetCategories', () {
    test('sorts categories by name, ignoring letter case', () async {
      repository.getResult = const Right<Failure, List<CategoryEntity>>([
        CategoryEntity(id: 1, name: 'shoes', slug: 'shoes'),
        CategoryEntity(id: 2, name: 'Bags', slug: 'bags'),
        CategoryEntity(id: 3, name: 'apple', slug: 'apple'),
      ]);

      final result = await GetCategories(repository)();

      final names = result.getOrElse(() => []).map((c) => c.name).toList();
      expect(names, ['apple', 'Bags', 'shoes']);
    });

    test('does not change the list returned by the repository', () async {
      const original = [
        CategoryEntity(id: 1, name: 'b', slug: 'b'),
        CategoryEntity(id: 2, name: 'a', slug: 'a'),
      ];
      repository.getResult = const Right<Failure, List<CategoryEntity>>(
        original,
      );

      await GetCategories(repository)();

      expect(original.first.name, 'b');
    });

    test('returns the failure as it is', () async {
      repository.getResult = const Left<Failure, List<CategoryEntity>>(
        Failure('No internet'),
      );

      final result = await GetCategories(repository)();

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, 'No internet'),
        (_) => fail('Expected a failure'),
      );
    });
  });

  group('AddCategory', () {
    test('passes name and description to the repository', () async {
      final result = await AddCategory(repository)(
        name: 'Shoes',
        description: 'All shoes',
      );

      expect(result.isRight(), true);
      expect(repository.calls, ['add:Shoes:All shoes']);
    });
  });

  group('UpdateCategory', () {
    test('passes slug, name and description to the repository', () async {
      final result = await UpdateCategory(repository)(
        slug: 'shoes',
        name: 'Sneakers',
      );

      expect(result.isRight(), true);
      expect(repository.calls, ['update:shoes:Sneakers:']);
    });
  });

  group('DeleteCategory', () {
    test('deletes by slug', () async {
      final result = await DeleteCategory(repository)('shoes');

      expect(result.isRight(), true);
      expect(repository.calls, ['delete:shoes']);
    });

    test('returns the failure when the repository fails', () async {
      repository.actionResult = const Left<Failure, Unit>(
        Failure('Forbidden', statusCode: 403),
      );

      final result = await DeleteCategory(repository)('shoes');

      result.fold(
        (f) => expect(f.statusCode, 403),
        (_) => fail('Expected a failure'),
      );
    });
  });
}
