import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static Future<void> load() => dotenv.load(fileName: '.env');

  static String get baseUrl => _require('BASE_URL');
  static String get apiKey => _require('API_KEY');

  static String _require(String key) {
    final value = dotenv.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw StateError('Missing "$key" in .env');
    }
    return value;
  }
}
