import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/admin/auth/domain/usecases/register_admin.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_cubit.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_fields.dart';
import 'package:easy_shop/features/admin/auth/presentation/cubit/register_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fake_auth_repository.dart';

Matcher _hasStatus(RegisterStatus status) {
  return isA<RegisterState>().having((s) => s.status, 'status', status);
}

void main() {
  late FakeAuthRepository repository;
  late RegisterCubit cubit;

  setUp(() {
    repository = FakeAuthRepository();
    cubit = RegisterCubit(RegisterAdmin(repository));
  });

  tearDown(() => cubit.close());

  void fillPersonal() {
    cubit.savePersonal(
      name: '  Ahmed Khalil ',
      email: ' ahmed@shop.com ',
      phone: '+20 101 311 4901',
      nationalId: ' 29801234567890 ',
    );
  }

  void fillBusiness({String address = ' 18 El Nasr Road '}) {
    cubit.saveBusiness(businessName: ' Khalil Store ', address: address);
  }

  Future<void> submit() {
    return cubit.submit(password: '12345678', passwordConfirmation: '12345678');
  }

  Failure failureWith(Map<String, List<String>> errors) {
    return Failure('Invalid data', statusCode: 422, fieldErrors: errors);
  }

  test('starts on the personal step with an empty draft', () {
    expect(cubit.state.step, RegisterStep.personal);
    expect(cubit.state.status, RegisterStatus.initial);
    expect(cubit.state.draft.name, isEmpty);
    expect(cubit.state.draft.hasLocation, isFalse);
  });

  group('steps', () {
    test('savePersonal trims the values and moves to the business step', () {
      fillPersonal();

      expect(cubit.state.step, RegisterStep.business);
      expect(cubit.state.draft.name, 'Ahmed Khalil');
      expect(cubit.state.draft.email, 'ahmed@shop.com');
      expect(cubit.state.draft.phone, '+20 101 311 4901');
      expect(cubit.state.draft.nationalId, '29801234567890');
    });

    test('saveBusiness trims the values and moves to the security step', () {
      fillPersonal();
      fillBusiness();

      expect(cubit.state.step, RegisterStep.security);
      expect(cubit.state.draft.businessName, 'Khalil Store');
      expect(cubit.state.draft.address, '18 El Nasr Road');
    });

    test('goBack moves one step back and keeps the draft', () {
      fillPersonal();
      fillBusiness();

      cubit.goBack();
      expect(cubit.state.step, RegisterStep.business);
      cubit.goBack();
      expect(cubit.state.step, RegisterStep.personal);
      expect(cubit.state.draft.name, 'Ahmed Khalil');
    });

    test('goBack stays on the first step', () {
      cubit.goBack();

      expect(cubit.state.step, RegisterStep.personal);
    });

    test('goBack is ignored while the form is loading', () async {
      fillPersonal();
      fillBusiness();
      final gate = Completer<void>();
      repository.registerGate = gate;

      final running = submit();
      cubit.goBack();
      gate.complete();
      await running;

      expect(cubit.state.step, RegisterStep.security);
    });
  });

  group('setters', () {
    test('keep the location and the picked files in the draft', () {
      cubit.setLocation(latitude: 30.0444, longitude: 31.2357);
      cubit.setCommercialRegister('/tmp/register.jpg');
      cubit.setTaxCard('/tmp/tax.jpg');
      cubit.setPicture('/tmp/photo.jpg');

      final draft = cubit.state.draft;
      expect(draft.latitude, 30.0444);
      expect(draft.longitude, 31.2357);
      expect(draft.hasLocation, isTrue);
      expect(draft.commercialRegisterPath, '/tmp/register.jpg');
      expect(draft.taxCardPath, '/tmp/tax.jpg');
      expect(draft.picturePath, '/tmp/photo.jpg');
    });

    test('each setter clears only its own field errors', () async {
      repository.registerResult = Left(
        failureWith({
          RegisterFields.latitude: ['Bad latitude'],
          RegisterFields.longitude: ['Bad longitude'],
          RegisterFields.taxCard: ['Bad tax card'],
          RegisterFields.picture: ['Bad picture'],
        }),
      );
      await submit();

      cubit.setLocation(latitude: 30, longitude: 31);
      expect(cubit.state.fieldError(RegisterFields.latitude), isNull);
      expect(cubit.state.fieldError(RegisterFields.longitude), isNull);
      expect(cubit.state.fieldError(RegisterFields.taxCard), 'Bad tax card');

      cubit.setTaxCard('/tmp/tax.jpg');
      expect(cubit.state.fieldError(RegisterFields.taxCard), isNull);
      expect(cubit.state.fieldError(RegisterFields.picture), 'Bad picture');

      cubit.setPicture('/tmp/photo.jpg');
      expect(cubit.state.fieldError(RegisterFields.picture), isNull);
    });
  });

  group('submit', () {
    test('emits loading then success', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          _hasStatus(RegisterStatus.loading),
          _hasStatus(RegisterStatus.success),
        ]),
      );

      await submit();
      await expectation;
    });

    test('sends the whole draft and the passwords to the use case', () async {
      fillPersonal();
      fillBusiness();
      cubit.setLocation(latitude: 30.0444, longitude: 31.2357);
      cubit.setPicture('/tmp/photo.jpg');
      cubit.setCommercialRegister('/tmp/register.jpg');
      cubit.setTaxCard('/tmp/tax.jpg');

      await submit();

      final sent = repository.registerArgs.single;
      expect(sent.name, 'Ahmed Khalil');
      expect(sent.email, 'ahmed@shop.com');
      expect(sent.phone, '+201013114901');
      expect(sent.nationalId, '29801234567890');
      expect(sent.businessName, 'Khalil Store');
      expect(sent.address, '18 El Nasr Road');
      expect(sent.password, '12345678');
      expect(sent.passwordConfirmation, '12345678');
      expect(sent.latitude, 30.0444);
      expect(sent.longitude, 31.2357);
      expect(sent.picturePath, '/tmp/photo.jpg');
      expect(sent.commercialRegisterPath, '/tmp/register.jpg');
      expect(sent.taxCardPath, '/tmp/tax.jpg');
    });

    test('sends no address when it was left empty', () async {
      fillPersonal();
      fillBusiness(address: '   ');

      await submit();

      expect(repository.registerArgs.single.address, isNull);
    });

    test('keeps the message on a failure without field errors', () async {
      repository.registerResult = const Left(
        Failure('No internet connection.'),
      );
      fillPersonal();
      fillBusiness();

      await submit();

      expect(cubit.state.status, RegisterStatus.error);
      expect(cubit.state.errorMessage, 'No internet connection.');
      expect(cubit.state.step, RegisterStep.security);
    });

    test('goes back to the step of the field that has an error', () async {
      repository.registerResult = Left(
        failureWith({
          RegisterFields.email: ['The email has already been taken.'],
        }),
      );
      fillPersonal();
      fillBusiness();
      expect(cubit.state.step, RegisterStep.security);

      await submit();

      expect(cubit.state.status, RegisterStatus.error);
      expect(cubit.state.step, RegisterStep.personal);
      expect(
        cubit.state.fieldError(RegisterFields.email),
        'The email has already been taken.',
      );
    });

    test('goes to the earliest step when several steps have errors', () async {
      repository.registerResult = Left(
        failureWith({
          RegisterFields.password: ['Too short'],
          RegisterFields.businessName: ['Required'],
        }),
      );
      fillPersonal();
      fillBusiness();

      await submit();

      expect(cubit.state.step, RegisterStep.business);
    });

    test('keeps the step when the error field is unknown', () async {
      repository.registerResult = Left(
        failureWith({
          'something_else': ['Unknown'],
        }),
      );
      fillPersonal();
      fillBusiness();

      await submit();

      expect(cubit.state.step, RegisterStep.security);
    });

    test('a new submit clears the old field errors', () async {
      repository.registerResult = Left(
        failureWith({
          RegisterFields.password: ['Too short'],
        }),
      );
      await submit();
      expect(cubit.state.fieldError(RegisterFields.password), isNotNull);

      repository.registerResult = const Right(unit);
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<RegisterState>()
              .having((s) => s.status, 'status', RegisterStatus.loading)
              .having((s) => s.fieldErrors, 'fieldErrors', isEmpty),
          _hasStatus(RegisterStatus.success),
        ]),
      );

      await submit();
      await expectation;
    });

    test('ignores a second submit while the first one is loading', () async {
      final gate = Completer<void>();
      repository.registerGate = gate;

      final first = submit();
      await submit();
      gate.complete();
      await first;

      expect(repository.registerArgs, hasLength(1));
    });

    test('does not emit a result after the cubit is closed', () async {
      final gate = Completer<void>();
      repository.registerGate = gate;
      final states = <RegisterState>[];
      cubit.stream.listen(states.add);

      final running = submit();
      await cubit.close();
      gate.complete();
      await running;

      expect(states.where((s) => s.status != RegisterStatus.loading), isEmpty);
    });
  });
}
