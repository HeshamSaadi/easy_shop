// The API returns the same field as a number in one response and as a string
// in another (for example price: 150 and price: "150"). These helpers accept
// both, so a model never crashes on the shape of a response.

int parseInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  if (value is String) return num.tryParse(value.trim())?.toInt() ?? fallback;
  return fallback;
}

double parseDouble(Object? value, {double fallback = 0}) {
  return parseNullableDouble(value) ?? fallback;
}

/// For optional values such as latitude and longitude, where null is valid.
double? parseNullableDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return num.tryParse(value.trim())?.toDouble();
  return null;
}

bool parseBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == '1' || text == 'true') return true;
    if (text == '0' || text == 'false') return false;
  }
  return fallback;
}

/// A nested object, or an empty map when it is missing or has another type.
Map<String, dynamic> parseMap(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}

/// A list of objects. Items that are not objects are skipped.
List<Map<String, dynamic>> parseMapList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().toList();
}
