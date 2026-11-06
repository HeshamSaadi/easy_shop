import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/admin/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/admin/categories/data/models/category_model.dart';
import 'package:easy_shop/features/admin/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements CategoryRemoteDataSource {
  Object? errorToThrow;
  List<CategoryModel> categories = const [];
  final List<String> calls = [];

  void _maybeThrow() {
    final error = errorToThrow;
    if (error != null) throw error;
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    calls.add('get');
    _maybeThrow();
    return categories;
  }

  @override
  Future<void> addCategory({required String name, String? description}) async {
    calls.add('add:$name');
    _maybeThrow();
  }

  @override
  Future<void> updateCategory({
    required String slug,
    required String name,
    String? description,
  }) async {
    calls.add('update:$slug');
    _maybeThrow();
  }

  @override
  Future<void> deleteCategory(String slug) async {
    calls.add('delete:$slug');
    _maybeThrow();
  }
}

void main() {
  late _FakeRemote remote;
  late CategoryRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    repository = CategoryRepositoryImpl(remote);
  });

  group('getCategories', () {
    test('returns the categories from the data source', () async {
      remote.categories = const [
        CategoryModel(id: 1, name: 'Shoes', slug: 'shoes'),
      ];

      final result = await repository.getCategories();

      result.fold(
        (_) => fail('Expected a list'),
        (list) => expect(list.single.slug, 'shoes'),
      );
    });

    test('turns an AppException into a Failure', () async {
      remote.errorToThrow = const NotFoundException();

      final result = await repository.getCategories();

      result.fold((f) {
        expect(f.statusCode, 404);
        expect(f.message, const NotFoundException().message);
      }, (_) => fail('Expected a failure'));
    });

    test('turns any other error into the unknown failure', () async {
      remote.errorToThrow = StateError('boom');

      final result = await repository.getCategories();

      result.fold(
        (f) => expect(f.message, const UnknownException().message),
        (_) => fail('Expected a failure'),
      );
    });
  });

  group('add / update / delete', () {
    test('addCategory returns Right on success', () async {
      final result = await repository.addCategory(name: 'Shoes');

      expect(result.isRight(), true);
      expect(remote.calls, ['add:Shoes']);
    });

    test('updateCategory keeps field errors of a bad request', () async {
      remote.errorToThrow = const BadRequestException(
        'Invalid',
        statusCode: 422,
        fieldErrors: {
          'name': ['Name is taken'],
        },
      );

      final result = await repository.updateCategory(
        slug: 'shoes',
        name: 'Bags',
      );

      result.fold((f) {
        expect(f.statusCode, 422);
        expect(f.fieldErrors['name'], ['Name is taken']);
      }, (_) => fail('Expected a failure'));
    });

    test('deleteCategory returns a failure on 403', () async {
      remote.errorToThrow = const ForbiddenException();

      final result = await repository.deleteCategory('shoes');

      result.fold(
        (f) => expect(f.statusCode, 403),
        (_) => fail('Expected a failure'),
      );
    });
  });
}
