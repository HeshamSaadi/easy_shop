import 'dart:convert';

/// Builds an unsigned, JWT-shaped string for tests.
///
/// `isJwtExpired` only reads the payload, so the header and the signature are
/// fixed placeholders. Pass [expiresIn] (negative means already expired) to
/// set the `exp` claim, or pass a full [payload] to control every claim.
String buildJwt({Duration? expiresIn, Map<String, dynamic>? payload}) {
  final claims =
      payload ??
      {
        if (expiresIn != null)
          'exp':
              DateTime.now().toUtc().add(expiresIn).millisecondsSinceEpoch ~/
              1000,
      };

  return [
    _encode({'alg': 'HS256', 'typ': 'JWT'}),
    _encode(claims),
    'signature',
  ].join('.');
}

String _encode(Map<String, dynamic> json) {
  return base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
}
