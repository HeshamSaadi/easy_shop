import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/categories/domain/entities/category_entity.dart';
import 'package:easy_shop/features/client/categories/domain/repositories/category_repository.dart';
import 'package:easy_shop/features/client/categories/domain/usecases/get_categories.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubCategoryRepository implements CategoryRepository {
  _StubCategoryRepository(this.result);

  final Either<Failure, List<CategoryEntity>> result;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async => result;
}

CategoryEntity _category(int id, String name) =>
    CategoryEntity(id: id, name: name, slug: 'slug-$id');

void main() {
  test('sorts by name, ignoring case', () async {
    final useCase = GetCategories(
      _StubCategoryRepository(
        Right([
          _category(1, 'laptops'),
          _category(2, 'Audio'),
          _category(3, 'Mobile'),
        ]),
      ),
    );

    final result = await useCase();

    final names = result.getOrElse(() => []).map((c) => c.name).toList();
    expect(names, ['Audio', 'laptops', 'Mobile']);
  });

  test('does not change the list it received', () async {
    final original = [_category(1, 'B'), _category(2, 'A')];
    final useCase = GetCategories(_StubCategoryRepository(Right(original)));

    await useCase();

    expect(original.map((c) => c.name).toList(), ['B', 'A']);
  });

  test('an empty list stays empty', () async {
    final useCase = GetCategories(_StubCategoryRepository(const Right([])));

    final result = await useCase();

    expect(result.getOrElse(() => [_category(0, 'x')]), isEmpty);
  });

  test('passes a failure through', () async {
    final useCase = GetCategories(
      _StubCategoryRepository(const Left(Failure('No internet'))),
    );

    final result = await useCase();

    expect(result.isLeft(), isTrue);
    result.fold((f) => expect(f.message, 'No internet'), (_) => fail('Right'));
  });
}
