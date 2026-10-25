import 'exceptions.dart';

class Failure {
  const Failure(this.message, {this.statusCode, this.fieldErrors = const {}});

  factory Failure.fromException(AppException exception) {
    return Failure(
      exception.message,
      statusCode: exception.statusCode,
      fieldErrors: exception.fieldErrors,
    );
  }

  final String message;
  final int? statusCode;

  final Map<String, List<String>> fieldErrors;
}
