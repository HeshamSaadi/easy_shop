import 'error_messages.dart';

abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class ConnectionTimeoutException extends AppException {
  const ConnectionTimeoutException() : super(ErrorMessages.timeout);
}

class NoInternetException extends AppException {
  const NoInternetException() : super(ErrorMessages.noInternet);
}

class BadRequestException extends AppException {
  const BadRequestException(super.message, {super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String? message])
    : super(message ?? ErrorMessages.unauthorized, statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException() : super(ErrorMessages.forbidden, statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException() : super(ErrorMessages.notFound, statusCode: 404);
}

class ServerException extends AppException {
  const ServerException({super.statusCode}) : super(ErrorMessages.server);
}

class UnknownException extends AppException {
  const UnknownException() : super(ErrorMessages.unknown);
}
