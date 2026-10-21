import 'package:easy_shop/core/databases/api/api_consumer.dart';

/// For tests that only need an ApiConsumer to exist.
class FakeApiConsumer implements ApiConsumer {
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    throw UnimplementedError();
  }
}
