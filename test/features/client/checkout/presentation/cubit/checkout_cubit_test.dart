import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/core/location/picked_location.dart';
import 'package:easy_shop/features/client/cart/domain/usecases/get_cart.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop/features/client/checkout/presentation/cubit/checkout_state.dart';
import 'package:easy_shop/features/client/orders/domain/entities/payment_method.dart';
import 'package:easy_shop/features/client/orders/domain/usecases/place_order.dart';
import 'package:easy_shop/features/client/profile/domain/usecases/get_client_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../cart/cart_test_helpers.dart';
import '../../../cart/fake_cart_repository.dart';
import '../../../orders/client_orders_test_helpers.dart';
import '../../../profile/fake_client_profile_repository.dart';

void main() {
  late FakeCartRepository cart;
  late FakeClientProfileRepository profile;
  late FakeClientOrdersRepository orders;
  late CheckoutCubit cubit;

  const pickedPlace = PickedLocation(
    latitude: 31.2,
    longitude: 29.9,
    address: 'Alexandria, Egypt',
  );

  setUp(() {
    cart = FakeCartRepository(items: [buildCartItem(price: 150, quantity: 2)]);
    profile = FakeClientProfileRepository();
    orders = FakeClientOrdersRepository();
    cubit = CheckoutCubit(
      getCart: GetCart(cart),
      getProfile: GetClientProfile(profile),
      placeOrder: PlaceOrder(orders),
    );
  });

  tearDown(() => cubit.close());

  CheckoutReady ready() => cubit.state as CheckoutReady;

  test('starts in CheckoutInitial', () {
    expect(cubit.state, isA<CheckoutInitial>());
  });

  group('load', () {
    test(
      'emits Loading then Ready with the items and the saved location',
      () async {
        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<CheckoutLoading>(),
            isA<CheckoutReady>()
                .having((s) => s.items.length, 'items', 1)
                .having((s) => s.location?.latitude, 'latitude', 30.0444)
                .having((s) => s.location?.longitude, 'longitude', 31.2357)
                .having(
                  (s) => s.location?.address,
                  'address',
                  '123 Tahrir Square, Cairo',
                )
                .having((s) => s.isPlacing, 'isPlacing', isFalse),
          ]),
        );

        await cubit.load();
        await expectation;
      },
    );

    test('a profile without coordinates gives no location', () async {
      profile.profileResult = Right(
        buildClient(latitude: null, longitude: null),
      );

      await cubit.load();

      expect(ready().location, isNull);
      expect(ready().hasLocation, isFalse);
    });

    test('a profile with only one coordinate gives no location', () async {
      profile.profileResult = Right(buildClient(longitude: null));

      await cubit.load();

      expect(ready().location, isNull);
    });

    test('a blank profile address becomes no address text', () async {
      profile.profileResult = Right(buildClient(address: '   '));

      await cubit.load();

      expect(ready().location?.address, isNull);
    });

    test('a failed profile request still loads, without a location', () async {
      profile.profileResult = const Left(Failure('Server error'));

      await cubit.load();

      expect(ready().items, hasLength(1));
      expect(ready().location, isNull);
    });

    test('a failed cart request emits Error with the message', () async {
      cart.getCartFailure = const Failure('No internet connection');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CheckoutLoading>(),
          isA<CheckoutError>().having(
            (s) => s.message,
            'message',
            'No internet connection',
          ),
        ]),
      );

      await cubit.load();
      await expectation;
    });

    test('an empty cart loads as Ready with no items', () async {
      cart.items = [];

      await cubit.load();

      expect(ready().items, isEmpty);
      expect(ready().canPlace, isFalse);
    });
  });

  group('setLocation', () {
    test('replaces the delivery point', () async {
      await cubit.load();

      cubit.setLocation(pickedPlace);

      expect(ready().location?.address, 'Alexandria, Egypt');
      expect(ready().location?.latitude, 31.2);
    });

    test('lets a user without a saved location choose one', () async {
      profile.profileResult = Right(
        buildClient(latitude: null, longitude: null),
      );
      await cubit.load();
      expect(ready().canPlace, isFalse);

      cubit.setLocation(pickedPlace);

      expect(ready().canPlace, isTrue);
    });

    test('is ignored before the checkout is loaded', () {
      cubit.setLocation(pickedPlace);

      expect(cubit.state, isA<CheckoutInitial>());
    });

    test('is ignored while the order is being placed', () async {
      await cubit.load();
      final gate = Completer<void>();
      orders.placeGate = gate;

      final placing = cubit.placeOrder();
      cubit.setLocation(pickedPlace);

      expect(ready().location?.address, '123 Tahrir Square, Cairo');

      gate.complete();
      await placing;
    });
  });

  group('canPlace', () {
    test('is true with a location, items and no problems', () async {
      await cubit.load();

      expect(ready().canPlace, isTrue);
    });

    test('is false without a delivery location', () async {
      profile.profileResult = Right(
        buildClient(latitude: null, longitude: null),
      );
      await cubit.load();

      expect(ready().canPlace, isFalse);
    });

    test('is false when an item is hidden', () async {
      cart.items = [buildCartItem(isVisible: false)];
      await cubit.load();

      expect(ready().hasProblems, isTrue);
      expect(ready().canPlace, isFalse);
    });

    test('is false when an item is above the stock', () async {
      cart.items = [buildCartItem(quantity: 5, stock: 3)];
      await cubit.load();

      expect(ready().hasProblems, isTrue);
      expect(ready().canPlace, isFalse);
    });
  });

  group('state values', () {
    test('total is the sum of the line totals', () async {
      cart.items = [
        buildCartItem(price: 150, quantity: 2),
        buildCartItem(productId: 2, price: 600),
      ];
      await cubit.load();

      expect(ready().total, 900);
    });

    test('deliveryAddress uses the address text when there is one', () async {
      await cubit.load();

      expect(ready().deliveryAddress, '123 Tahrir Square, Cairo');
    });

    test('deliveryAddress falls back to the coordinates', () async {
      profile.profileResult = Right(buildClient(address: null));
      await cubit.load();

      expect(ready().deliveryAddress, '30.04440, 31.23570');
    });

    test('deliveryAddress is empty without a location', () async {
      profile.profileResult = Right(
        buildClient(latitude: null, longitude: null),
      );
      await cubit.load();

      expect(ready().deliveryAddress, '');
    });

    test(
      'copyWith clears the old actionError unless a new one is given',
      () async {
        await cubit.load();
        final withError = ready().copyWith(actionError: 'Server error');

        expect(withError.actionError, 'Server error');
        expect(withError.copyWith().actionError, isNull);
      },
    );
  });

  group('placeOrder', () {
    test('builds the lines from the cart items, price from the cart', () async {
      cart.items = [
        buildCartItem(productId: 32, price: 220, quantity: 2),
        buildCartItem(productId: 33, price: 600),
      ];
      await cubit.load();

      await cubit.placeOrder();

      final params = orders.placedParams.single;
      expect(params.lines.map((line) => line.productId), [32, 33]);
      expect(params.lines.map((line) => line.quantity), [2, 1]);
      expect(params.lines.map((line) => line.price), [220, 600]);
    });

    test('sends the delivery address, coordinates and cash', () async {
      await cubit.load();

      await cubit.placeOrder();

      final params = orders.placedParams.single;
      expect(params.address, '123 Tahrir Square, Cairo');
      expect(params.latitude, 30.0444);
      expect(params.longitude, 31.2357);
      expect(params.paymentMethod, PaymentMethod.cash);
    });

    test('sends the location picked on the map', () async {
      await cubit.load();
      cubit.setLocation(pickedPlace);

      await cubit.placeOrder();

      final params = orders.placedParams.single;
      expect(params.address, 'Alexandria, Egypt');
      expect(params.latitude, 31.2);
      expect(params.longitude, 29.9);
    });

    test('shows the placing state, then emits Placed with the order', () async {
      orders.placeResult = Right(buildOrder(code: 'NEWORDER'));
      await cubit.load();

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CheckoutReady>().having((s) => s.isPlacing, 'isPlacing', isTrue),
          isA<CheckoutPlaced>().having((s) => s.order.code, 'code', 'NEWORDER'),
        ]),
      );

      await cubit.placeOrder();
      await expectation;
    });

    test('a failed order keeps the screen and shows the message', () async {
      orders.placeResult = const Left(
        Failure('The quantity.0 field must be less than or equal to 40.'),
      );
      await cubit.load();

      await cubit.placeOrder();

      final state = ready();
      expect(state.isPlacing, isFalse);
      expect(state.items, hasLength(1));
      expect(state.location, isNotNull);
      expect(state.actionError, contains('less than or equal to 40'));
    });

    test('a failed order can be tried again', () async {
      orders.placeResult = const Left(Failure('Server error'));
      await cubit.load();
      await cubit.placeOrder();

      orders.placeResult = Right(buildOrder());
      await cubit.placeOrder();

      expect(orders.placedParams, hasLength(2));
      expect(cubit.state, isA<CheckoutPlaced>());
    });

    test('does nothing before the checkout is loaded', () async {
      await cubit.placeOrder();

      expect(orders.placedParams, isEmpty);
      expect(cubit.state, isA<CheckoutInitial>());
    });

    test('does nothing without a delivery location', () async {
      profile.profileResult = Right(
        buildClient(latitude: null, longitude: null),
      );
      await cubit.load();

      await cubit.placeOrder();

      expect(orders.placedParams, isEmpty);
    });

    test('does nothing when an item is hidden', () async {
      cart.items = [buildCartItem(isVisible: false)];
      await cubit.load();

      await cubit.placeOrder();

      expect(orders.placedParams, isEmpty);
    });

    test('does nothing when an item is above the stock', () async {
      cart.items = [buildCartItem(quantity: 5, stock: 3)];
      await cubit.load();

      await cubit.placeOrder();

      expect(orders.placedParams, isEmpty);
    });

    test('does nothing when the cart is empty', () async {
      cart.items = [];
      await cubit.load();

      await cubit.placeOrder();

      expect(orders.placedParams, isEmpty);
    });
  });

  group('no double submit', () {
    test(
      'a second tap while the order is being placed sends nothing',
      () async {
        await cubit.load();
        final gate = Completer<void>();
        orders.placeGate = gate;

        final first = cubit.placeOrder();
        final second = cubit.placeOrder();

        expect(ready().isPlacing, isTrue);
        expect(ready().canPlace, isFalse);

        gate.complete();
        await Future.wait([first, second]);

        expect(orders.placedParams, hasLength(1));
        expect(cubit.state, isA<CheckoutPlaced>());
      },
    );
  });
}
