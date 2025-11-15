import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String apiBaseUrl = 'http://localhost:3000';
  static int defaultUserId = 1;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Ignore missing env files in dev environments.
    }

    apiBaseUrl = dotenv.maybeGet('API_BASE_URL') ?? apiBaseUrl;
    final defaultUserString = dotenv.maybeGet('DEFAULT_USER_ID');
    final parsedDefaultUserId = int.tryParse(defaultUserString ?? '');
    if (parsedDefaultUserId != null) {
      defaultUserId = parsedDefaultUserId;
    }
  }
}
