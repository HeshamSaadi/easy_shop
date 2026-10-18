const _messageKey = 'message';
const _messageSeparator = '\n';

class ErrorModel {
  const ErrorModel({this.message, this.fieldErrors = const {}});

  factory ErrorModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return const ErrorModel();

    final raw = json[_messageKey];
    if (raw is String) {
      return ErrorModel(message: raw.isEmpty ? null : raw);
    }
    if (raw is Map) return ErrorModel._fromFieldErrors(raw);
    return const ErrorModel();
  }

  factory ErrorModel._fromFieldErrors(Map<dynamic, dynamic> raw) {
    final fields = <String, List<String>>{};
    raw.forEach((key, value) {
      if (key is String && value is List) {
        fields[key] = value.whereType<String>().toList();
      }
    });

    final allMessages = fields.values.expand((list) => list).toList();
    return ErrorModel(
      message: allMessages.isEmpty ? null : allMessages.join(_messageSeparator),
      fieldErrors: fields,
    );
  }

  final String? message;

  final Map<String, List<String>> fieldErrors;
}