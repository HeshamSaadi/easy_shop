import 'dart:io';

import 'package:dio/dio.dart';

import '../cache/token_storage.dart';
import 'session_events.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage, required this._sessionEvents});

  static const _bearerPrefix = 'Bearer ';

  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = '$_bearerPrefix$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final hadToken = err.requestOptions.headers.containsKey(
      HttpHeaders.authorizationHeader,
    );
    if (err.response?.statusCode == HttpStatus.unauthorized && hadToken) {
      await _tokenStorage.clearToken();
      _sessionEvents.notifySessionExpired();
    }
    handler.next(err);
  }
}
