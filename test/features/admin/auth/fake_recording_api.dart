import 'package:easy_shop/core/databases/api/api_consumer.dart';

import '../../../helpers/fake_api_consumer.dart';

/// Records every `post` call, and answers with [response] or throws [error].
class RecordingApiConsumer extends FakeApiConsumer implements ApiConsumer {
  dynamic response;
  Object? error;

  final List<({String path, Object? data})> postCalls = [];

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    postCalls.add((path: path, data: data));
    final failure = error;
    if (failure != null) throw failure;
    return response;
  }
}
