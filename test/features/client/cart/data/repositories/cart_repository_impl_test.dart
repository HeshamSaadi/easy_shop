import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/features/client/cart/data/datasources/cart_remote_data_source.dart';
import 'package:easy_shop/features/client/cart/data/models/cart_item_model.dart';
import 'package:easy_shop/features/client/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../cart_test_helpers.dart';

/// Hand-written fake. Set [error] to make every call throw it, or
/// [unexpectedError] to throw something that is not an AppException.
class _FakeCartRemoteDataSource implements CartRemoteDataSource {
  List<CartItemModel> items = [];
  AppException? error;
  bool unexpectedError = false;

  ({int productId, int quantity})? lastSet;
  int? lastRemoved;

  void _throwIfNeeded() {
    final appError = error;
    if (appError != null) throw appError;
    if (unexpectedError) throw StateError('unexpected');
  }

  @override
  Future<List<CartItemModel>> getCart() async {
    _throwIfNeeded();
    return items;
  }

  @override
  Future<void> setQuantity({
    required int productId,
    required int quantity,
  }) async {
    _throwIfNeeded();
    lastSet = (productId: productId, quantity: quantity);
  }

  @override
  Future<void> removeFromCart(int productId) async {
    _throwIfNeeded();
    lastRemoved = productId;
  }
}

void main() {
  late _FakeCartRemoteDataSource remote;
  late CartRepositoryImpl repository;

  setUp(() {
    remote = _FakeCartRemoteDataSource();
    repository = CartRepositoryImpl(remote);
  });

  group('getCart', () {
    test('returns the items from the data source', () async {
      remote.items = [CartItemModel.fromJson(cartItemJson())];

      final items = rightOf(await repository.getCart());

      expect(items.single.product.id, 32);
      expect(items.single.quantity, 2);
    });

    test('turns an AppException into a Failure', () async {
      remote.error = const ServerException();

      final failure = leftOf(await repository.getCart());

      expect(failure.message, const ServerException().message);
    });

    test('turns an unexpected error into a Failure', () async {
      remote.unexpectedError = true;

      final failure = leftOf(await repository.getCart());

      expect(failure.message, const UnknownException().message);
    });
  });

  group('setQuantity', () {
    test('sends the arguments to the data source', () async {
      final result = await repository.setQuantity(productId: 7, quantity: 4);

      expect(result.isRight(), isTrue);
      expect(remote.lastSet?.productId, 7);
      expect(remote.lastSet?.quantity, 4);
    });

    test('turns an exception into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.setQuantity(productId: 7, quantity: 4);

      expect(result.isLeft(), isTrue);
    });
  });

  group('removeFromCart', () {
    test('sends the product id to the data source', () async {
      final result = await repository.removeFromCart(7);

      expect(result.isRight(), isTrue);
      expect(remote.lastRemoved, 7);
    });

    test('turns an exception into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.removeFromCart(7);

      expect(result.isLeft(), isTrue);
    });
  });
}
