import 'package:easy_shop/core/errors/exceptions.dart';
import 'package:easy_shop/core/errors/failure.dart';
import 'package:easy_shop/features/client/profile/data/datasources/profile_remote_data_source.dart';
import 'package:easy_shop/features/client/profile/data/models/client_model.dart';
import 'package:easy_shop/features/client/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

const _client = ClientModel(
  id: 1,
  name: 'Ahmed',
  email: 'ahmed@example.com',
  phone: '+201013114901',
);

/// Hand-written fake. Set [error] to throw an AppException, or
/// [unexpectedError] to throw something that is not one.
class _FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  AppException? error;
  bool unexpectedError = false;

  int getCalls = 0;
  String? lastName;
  String? lastPicturePath;

  void _throwIfNeeded() {
    final appError = error;
    if (appError != null) throw appError;
    if (unexpectedError) throw StateError('unexpected');
  }

  @override
  Future<ClientModel> getProfile() async {
    getCalls++;
    _throwIfNeeded();
    return _client;
  }

  @override
  Future<ClientModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? address,
    double? latitude,
    double? longitude,
    String? picturePath,
  }) async {
    lastName = name;
    lastPicturePath = picturePath;
    _throwIfNeeded();
    return _client;
  }
}

Failure _left(dynamic result) =>
    (result as dynamic).fold((f) => f as Failure, (_) => fail('Expected Left'));

void main() {
  late _FakeProfileRemoteDataSource remote;
  late ProfileRepositoryImpl repository;

  setUp(() {
    remote = _FakeProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remote);
  });

  group('getProfile', () {
    test('returns the client from the data source', () async {
      final result = await repository.getProfile();

      expect(result.fold((_) => null, (c) => c.id), 1);
      expect(remote.getCalls, 1);
    });

    test('turns an AppException into a Failure', () async {
      remote.error = const ServerException();

      final failure = _left(await repository.getProfile());

      expect(failure.message, const ServerException().message);
    });

    test('turns an unexpected error into a Failure', () async {
      remote.unexpectedError = true;

      final failure = _left(await repository.getProfile());

      expect(failure.message, const UnknownException().message);
    });
  });

  group('updateProfile', () {
    test('sends the arguments and returns the updated client', () async {
      final result = await repository.updateProfile(
        name: 'Ahmed Hassan',
        email: 'ahmed@example.com',
        phone: '+201013114901',
        picturePath: '/tmp/photo.jpg',
      );

      expect(result.isRight(), isTrue);
      expect(remote.lastName, 'Ahmed Hassan');
      expect(remote.lastPicturePath, '/tmp/photo.jpg');
    });

    test('turns an AppException into a Failure', () async {
      remote.error = const ServerException();

      final result = await repository.updateProfile(
        name: 'Ahmed',
        email: 'ahmed@example.com',
        phone: '+201013114901',
      );

      expect(_left(result).message, const ServerException().message);
    });

    test('turns an unexpected error into a Failure', () async {
      remote.unexpectedError = true;

      final result = await repository.updateProfile(
        name: 'Ahmed',
        email: 'ahmed@example.com',
        phone: '+201013114901',
      );

      expect(_left(result).message, const UnknownException().message);
    });
  });
}
