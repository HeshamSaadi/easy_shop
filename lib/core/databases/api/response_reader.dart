import 'package:easy_shop/core/errors/exceptions.dart';

/// Reads the `data` field of the API envelope `{ data, message }`.
abstract final class ResponseReader {
  static const String _dataKey = 'data';
  static const String _tokenKey = 'token';

  static Map<String, dynamic> object(dynamic response) {
    final data = _data(response);
    if (data is! Map<String, dynamic>) throw const ServerException();
    return data;
  }

  static List<Map<String, dynamic>> list(dynamic response) {
    final data = _data(response);
    if (data is! List) throw const ServerException();
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static dynamic _data(dynamic response) {
    return response is Map<String, dynamic> ? response[_dataKey] : null;
  }

  static String token(dynamic response) {
    final value = response is Map<String, dynamic> ? response[_tokenKey] : null;
    if (value is! String || value.isEmpty) throw const ServerException();
    return value;
  }
}
