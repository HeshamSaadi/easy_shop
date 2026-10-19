import 'dart:io';

import 'package:dio/dio.dart';

import '../cache/token_storage.dart';
import 'session_events.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage, required this._sessionEvents});

  static const _bearerPrefix = 'Bearer ';

  static const _publicPaths = [
    '/login',
    '/register',
    '/otp/verify',
    '/otp/resend',
  ];

  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;

  bool _isPublic(String path) => _publicPaths.any(path.endsWith);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readToken();
    if (!_isPublic(options.path) && token != null && token.isNotEmpty) {
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
