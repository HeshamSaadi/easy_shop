import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/media/image_picker_service.dart';
import 'package:easy_shop/features/admin/products/domain/entities/product_entity.dart';
import 'package:easy_shop/features/admin/products/domain/params/product_params.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/create_product.dart';
import 'package:easy_shop/features/admin/products/domain/usecases/update_product.dart';
import 'package:easy_shop/features/admin/products/presentation/constants/products_strings.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_cubit.dart';
import 'package:easy_shop/features/admin/products/presentation/cubit/product_form_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../home/home_test_helpers.dart'
    show FakeGetCategories, buildCategory;
import '../../products_test_helpers.dart';

/// Hand-written fake for the gallery. Returns [path] (null means the user
/// cancelled) or throws [error] when it is set.
class _FakeImagePicker implements ImagePickerService {
  String? path;
  Object? error;
  int pickCalls = 0;

  @override
  Future<String?> pickImage() async {
    pickCalls++;
    final failure = error;
    if (failure != null) throw failure;
    return path;
  }
}

/// Holds the create request until [release] is completed, so a test can
/// submit again while the first request is still running.
class _PausedCreateRepository extends FakeProductsRepository {
  final Completer<void> release = Completer<void>();
  int createCalls = 0;

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductParams params,
  ) async {
    createCalls++;
    await release.future;
    return productResult;
  }
}

/// Submits valid values. Pass [slug] to edit, or change a field to test it.
Future<void> _submit(
  ProductFormCubit cubit, {
  String? slug,
  String price = '150',
  String quantity = '10',
}) {
  return cubit.submit(
    slug: slug,
    name: 'Smart Watch',
    price: price,
    quantity: quantity,
    categoryId: 2,
    isVisible: true,
  );
}

void main() {
  late FakeProductsRepository repository;
  late FakeGetCategories categories;
  late _FakeImagePicker picker;
  late ProductFormCubit cubit;

  ProductFormCubit buildCubit(FakeProductsRepository repo) {
    return ProductFormCubit(
      getCategories: categories,
      createProduct: CreateProduct(repo),
      updateProduct: UpdateProduct(repo),
      imagePicker: picker,
    );
  }

  setUp(() {
    repository = FakeProductsRepository();
    categories = FakeGetCategories();
    picker = _FakeImagePicker();
    cubit = buildCubit(repository);
  });

  tearDown(() => cubit.close());

  group('loadCategories', () {
    test('starts in ProductFormLoading', () {
      expect(cubit.state, isA<ProductFormLoading>());
    });

    test('emits Loading then Ready with the categories', () async {
      categories.result = Right([
        buildCategory('Electronics'),
        buildCategory('Clothing'),
      ]);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductFormLoading>(),
          isA<ProductFormReady>().having(
            (s) => s.categories.map((category) => category.name).toList(),
            'names',
            ['Electronics', 'Clothing'],
          ),
        ]),
      );

      await cubit.loadCategories();
      await expectation;
    });

    test('with no categories emits Ready with an empty list', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductFormLoading>(),
          isA<ProductFormReady>().having((s) => s.categories, 'list', isEmpty),
        ]),
      );

      await cubit.loadCategories();
      await expectation;
    });

    test('emits Loading then LoadError with the failure message', () async {
      categories.result = const Left(Failure('No internet'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ProductFormLoading>(),
          isA<ProductFormLoadError>().having(
            (s) => s.message,
            'message',
            'No internet',
          ),
        ]),
      );

      await cubit.loadCategories();
      await expectation;
    });
  });

  group('before the form is ready', () {
    test('pickImage is ignored', () async {
      await cubit.pickImage();

      expect(picker.pickCalls, 0);
      expect(cubit.state, isA<ProductFormLoading>());
    });

    test('submit is ignored', () async {
      await _submit(cubit);

      expect(repository.receivedParams, isNull);
      expect(cubit.state, isA<ProductFormLoading>());
    });
  });

  group('after the categories loaded', () {
    setUp(() async {
      categories.result = Right([buildCategory('Electronics')]);
      await cubit.loadCategories();
    });

    group('pickImage', () {
      test('stores the picked image path', () async {
        picker.path = '/photos/watch.jpg';

        final expectation = expectLater(
          cubit.stream,
          emits(
            isA<ProductFormReady>().having(
              (s) => s.imagePath,
              'imagePath',
              '/photos/watch.jpg',
            ),
          ),
        );

        await cubit.pickImage();
        await expectation;
      });

      test('does nothing when the user cancels', () async {
        final before = cubit.state;

        await cubit.pickImage();

        expect(cubit.state, same(before));
      });

      test('shows a message when the picker fails', () async {
        picker.error = Exception('boom');

        final expectation = expectLater(
          cubit.stream,
          emits(
            isA<ProductFormReady>().having(
              (s) => s.message,
              'message',
              ProductsStrings.imagePickFailed,
            ),
          ),
        );

        await cubit.pickImage();
        await expectation;
      });
    });

    group('submit', () {
      test('create sends the trimmed values to CreateProduct', () async {
        await cubit.submit(
          name: '  Smart Watch  ',
          price: ' 150.5 ',
          quantity: ' 10 ',
          categoryId: 2,
          isVisible: false,
          description: '  Nice watch  ',
        );

        final params = repository.receivedParams;
        expect(params?.name, 'Smart Watch');
        expect(params?.price, 150.5);
        expect(params?.quantity, 10);
        expect(params?.categoryId, 2);
        expect(params?.isVisible, isFalse);
        expect(params?.description, 'Nice watch');
        expect(params?.imagePath, isNull);
        expect(repository.requestedSlug, isNull);
      });

      test('a slug means update: UpdateProduct gets that slug', () async {
        await _submit(cubit, slug: 'smart-watch');

        expect(repository.requestedSlug, 'smart-watch');
        expect(repository.receivedParams, isNotNull);
      });

      test('sends the picked image path', () async {
        picker.path = '/photos/watch.jpg';
        await cubit.pickImage();

        await _submit(cubit);

        expect(repository.receivedParams?.imagePath, '/photos/watch.jpg');
      });

      test('emits isSubmitting then Success', () async {
        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<ProductFormReady>().having(
              (s) => s.isSubmitting,
              'isSubmitting',
              true,
            ),
            isA<ProductFormSuccess>(),
          ]),
        );

        await _submit(cubit);
        await expectation;
      });

      test('a failed save goes back to Ready with the message', () async {
        repository.productResult = const Left(Failure('Server error'));

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<ProductFormReady>().having(
              (s) => s.isSubmitting,
              'isSubmitting',
              true,
            ),
            isA<ProductFormReady>()
                .having((s) => s.isSubmitting, 'isSubmitting', false)
                .having((s) => s.message, 'message', 'Server error'),
          ]),
        );

        await _submit(cubit);
        await expectation;
      });

      test('an invalid price shows a message and sends nothing', () async {
        final expectation = expectLater(
          cubit.stream,
          emits(
            isA<ProductFormReady>().having(
              (s) => s.message,
              'message',
              ProductsStrings.invalidNumbers,
            ),
          ),
        );

        await _submit(cubit, price: 'abc');
        await expectation;

        expect(repository.receivedParams, isNull);
      });

      test('a decimal quantity shows a message and sends nothing', () async {
        final expectation = expectLater(
          cubit.stream,
          emits(
            isA<ProductFormReady>().having(
              (s) => s.message,
              'message',
              ProductsStrings.invalidNumbers,
            ),
          ),
        );

        await _submit(cubit, quantity: '1.5');
        await expectation;

        expect(repository.receivedParams, isNull);
      });

      test('a second submit is ignored while one is running', () async {
        final paused = _PausedCreateRepository();
        final pausedCubit = buildCubit(paused);
        await pausedCubit.loadCategories();

        final firstSubmit = _submit(pausedCubit);
        await _submit(pausedCubit);

        expect(paused.createCalls, 1);

        paused.release.complete();
        await firstSubmit;

        expect(pausedCubit.state, isA<ProductFormSuccess>());
        await pausedCubit.close();
      });
    });
  });
}
