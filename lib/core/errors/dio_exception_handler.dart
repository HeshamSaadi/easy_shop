import 'dart:io';

import 'package:dio/dio.dart';

import 'error_messages.dart';
import 'exceptions.dart';

Never handleDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      throw const ConnectionTimeoutException();
    case DioExceptionType.connectionError:
      throw const NoInternetException();
    case DioExceptionType.badResponse:
      throw _fromResponse(e.response);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      throw const UnknownException();
  }
}

AppException _fromResponse(Response<dynamic>? response) {
  final code = response?.statusCode;
  switch (code) {
    case HttpStatus.badRequest:
    case HttpStatus.unprocessableEntity:
      return BadRequestException(
        _extractMessage(response?.data) ?? ErrorMessages.unknown,
        statusCode: code,
      );
    case HttpStatus.unauthorized:
      return UnauthorizedException(_extractMessage(response?.data));
    case HttpStatus.forbidden:
      return const ForbiddenException();
    case HttpStatus.notFound:
      return const NotFoundException();
    default:
      if (code != null && code >= HttpStatus.internalServerError) {
        return ServerException(statusCode: code);
      }
      return const UnknownException();
  }
}

const _messageKey = 'message';
const _validationSeparator = '\n';

String? _extractMessage(dynamic data) {
  if (data is! Map<String, dynamic>) return null;

  final value = data[_messageKey];
  if (value is String) return value.isEmpty ? null : value;
  if (value is Map) return _flattenValidationErrors(value);
  return null;
}

String? _flattenValidationErrors(Map<dynamic, dynamic> errors) {
  final messages = errors.values
      .whereType<List<dynamic>>()
      .expand((list) => list.whereType<String>())
      .toList();
  return messages.isEmpty ? null : messages.join(_validationSeparator);
}
