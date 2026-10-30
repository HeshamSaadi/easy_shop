import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/delete_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/get_product_details.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_details_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products_test_helpers.dart';

/// Holds the delete until [release] is completed, so a test can call
/// delete again while the first one is still running.
class _PausedDeleteRepository extends FakeProductsRepository {
  final Completer<void> release = Completer<void>();
  int deleteCalls = 0;

  @override
  Future<Either<Failure, Unit>> deleteProduct(String slug) async {
    deleteCalls++;
    await release.future;
    return deleteResult;
  }
}

ProductDetailsCubit _buildCubit(FakeProductsRepository repository) {
  return ProductDetailsCubit(
    getProductDetails: GetProductDetails(repository),
    deleteProduct: DeleteProduct(repository),
    slug: 'smart-watch',
  );
}

void main() {
  late FakeProductsRepository repository;
  late ProductDetailsCubit cubit;

  setUp(() {
    repository = FakeProductsRepository();
    cubit = _buildCubit(repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('starts in ProductDetailsInitial', () {
      expect(cubit.state, isA<ProductDetailsInitial>());
    });

    test('emits Loading then Loaded with the product', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsLoaded>().having(
            (s) => s.product.slug,
            'slug',
            'smart-watch',
          ),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('asks the repository for the slug it was given', () async {
      await cubit.load();

      expect(repository.requestedSlug, 'smart-watch');
    });

    test('emits Loading then Error with the failure message', () async {
      repository.productResult = const Left(Failure('Product is not found'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductDetailsLoading>(),
          isA<ProductDetailsError>().having(
            (s) => s.message,
            'message',
            'Product is not found',
          ),
        ]),
      );

      await cubit.load();
      await expectation;
    });
  });

  group('delete', () {
    test('emits isDeleting then Deleted on success', () async {
      await cubit.load();

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductDetailsLoaded>().having(
            (s) => s.isDeleting,
            'isDeleting',
            true,
          ),
          isA<ProductDetailsDeleted>(),
        ]),
      );

      await cubit.delete();
      await expectation;
    });

    test('deletes the slug of the loaded product', () async {
      await cubit.load();
      repository.requestedSlug = null;

      await cubit.delete();

      expect(repository.requestedSlug, 'smart-watch');
    });

    test('a failed delete keeps the product and sets actionError', () async {
      await cubit.load();
      repository.deleteResult = const Left(Failure('Server error'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductDetailsLoaded>().having(
            (s) => s.isDeleting,
            'isDeleting',
            true,
          ),
          isA<ProductDetailsLoaded>()
              .having((s) => s.isDeleting, 'isDeleting', false)
              .having((s) => s.actionError, 'actionError', 'Server error')
              .having((s) => s.product.slug, 'slug', 'smart-watch'),
        ]),
      );

      await cubit.delete();
      await expectation;
    });

    test('a second delete is ignored while one is running', () async {
      final paused = _PausedDeleteRepository();
      final pausedCubit = _buildCubit(paused);
      await pausedCubit.load();

      final firstDelete = pausedCubit.delete();
      await pausedCubit.delete();

      expect(paused.deleteCalls, 1);

      paused.release.complete();
      await firstDelete;

      expect(pausedCubit.state, isA<ProductDetailsDeleted>());
      await pausedCubit.close();
    });

    test('does nothing before the product is loaded', () async {
      await cubit.delete();

      expect(cubit.state, isA<ProductDetailsInitial>());
      expect(repository.requestedSlug, isNull);
    });
  });
}
