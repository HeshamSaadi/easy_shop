import 'dart:io';

import 'package:dio/dio.dart';

import 'error_messages.dart';
import 'error_model.dart';
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
      final error = ErrorModel.fromJson(response?.data);
      return BadRequestException(
        error.message ?? ErrorMessages.unknown,
        statusCode: code,
        fieldErrors: error.fieldErrors,
      );
    case HttpStatus.unauthorized:
      return UnauthorizedException(ErrorModel.fromJson(response?.data).message);
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
