import 'dart:convert';

bool isJwtExpired(
  String token, {
  Duration leeway = const Duration(seconds: 30),
}) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'];
    if (exp is! num) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().isAfter(expiry.subtract(leeway));
  } catch (_) {
    return true;
  }
}
