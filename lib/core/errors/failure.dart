import 'exceptions.dart';

class Failure {
  const Failure(this.message, {this.statusCode});

  factory Failure.fromException(AppException exception) {
    return Failure(exception.message, statusCode: exception.statusCode);
  }

  final String message;
  final int? statusCode;
}