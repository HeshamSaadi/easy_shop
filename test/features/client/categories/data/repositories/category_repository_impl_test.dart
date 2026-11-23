import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/categories/data/datasources/category_remote_data_source.dart';
import 'package:easy_shop/features/client/categories/data/models/category_model.dart';
import 'package:easy_shop/features/client/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-written fake. Set [error] to make the call throw it, or
/// [unexpectedError] to throw something that is not an AppException.
class _FakeCategoryRemoteDataSource implements CategoryRemoteDataSource {
  List<CategoryModel> categories = [];
  AppException? error;
  bool unexpectedError = false;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final appError = error;
    if (appError != null) throw appError;
    if (unexpectedError) throw StateError('unexpected');
    return categories;
  }
}

void main() {
  late _FakeCategoryRemoteDataSource remote;
  late CategoryRepositoryImpl repository;

  setUp(() {
    remote = _FakeCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remote);
  });

  test('returns the categories from the data source', () async {
    remote.categories = [
      CategoryModel.fromJson({'id': 1, 'name': 'Audio', 'slug': 'audio'}),
    ];

    final result = await repository.getCategories();

    final categories = result.getOrElse(() => []);
    expect(categories.single.name, 'Audio');
  });

  test('turns an AppException into a Failure', () async {
    remote.error = const ServerException();

    final result = await repository.getCategories();

    result.fold(
      (failure) => expect(failure.message, const ServerException().message),
      (_) => fail('expected a Failure'),
    );
  });

  test('turns an unexpected error into a Failure', () async {
    remote.unexpectedError = true;

    final result = await repository.getCategories();

    result.fold(
      (failure) => expect(failure.message, const UnknownException().message),
      (_) => fail('expected a Failure'),
    );
  });
}
