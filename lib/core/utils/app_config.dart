import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({required this.baseUrl, required this.apiKey});

  final String baseUrl;
  final String apiKey;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String _envFile = '.env';
  static const String _baseUrlKey = 'BASE_URL';
  static const String _apiKeyKey = 'API_KEY';

  static Future<AppConfig> load() async {
    await dotenv.load(fileName: _envFile);
    final baseUrl = dotenv.maybeGet(_baseUrlKey);
    final apiKey = dotenv.maybeGet(_apiKeyKey);

    if (baseUrl == null ||
        baseUrl.isEmpty ||
        apiKey == null ||
        apiKey.isEmpty) {
      throw StateError('Missing $_baseUrlKey or $_apiKeyKey in $_envFile');
    }
    return AppConfig(baseUrl: baseUrl, apiKey: apiKey);
  }
}
