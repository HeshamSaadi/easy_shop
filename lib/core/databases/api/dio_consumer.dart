import 'package:dio/dio.dart';
import 'package:easy_shop/core/databases/api/api_consumer.dart';
import 'package:easy_shop/core/databases/api/auth_interceptor.dart';
import 'package:easy_shop/core/databases/api/session_events.dart';
import 'package:easy_shop/core/databases/cache/token_storage.dart';
import 'package:easy_shop/core/errors/dio_exception_handler.dart';
import 'package:easy_shop/core/utils/app_config.dart';

class DioConsumer implements ApiConsumer {
  DioConsumer({
    required this._dio,
    required TokenStorage tokenStorage,
    required SessionEvents sessionEvents,
  }) {
    _dio.options
      ..baseUrl = AppConfig.baseUrl
      ..connectTimeout = AppConfig.connectTimeout
      ..receiveTimeout = AppConfig.receiveTimeout
      ..headers = {'x-api-key': AppConfig.apiKey, 'Accept': 'application/json'};

    _dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, sessionEvents: sessionEvents),
    );
  }

  final Dio _dio;

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.put(path, data: data, queryParameters: queryParameters),
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.delete(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
}
