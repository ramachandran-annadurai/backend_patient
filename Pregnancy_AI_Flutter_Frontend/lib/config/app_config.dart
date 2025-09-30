import 'package:flutter/services.dart';

enum Environment { dev, prod }

class AppConfig {
  static late Environment environment;

  // Feature flags derived from environment
  static bool get isFirebaseEnabled => environment == Environment.prod;

  // Optional proxy flag from build-time define
  static const String isProxyEnabled =
      String.fromEnvironment('PROXYIP_ENABLED', defaultValue: 'true');

  // App strings/URLs derived from environment
  static String get appTitle =>
      environment == Environment.prod ? 'Spotless' : 'Spotless (Dev)';

  static String get baseUrl => environment == Environment.prod
      ? 'https://tgpb7uf2hi.execute-api.ap-south-1.amazonaws.com/prod'
      : 'https://lj9zar0aqd.execute-api.ap-south-1.amazonaws.com/dev';

  static String get appUrl => baseUrl;

  // Platform information for API headers
  static String get platform {
    // You can make this more sophisticated based on your needs
    return 'flutter';
  }

  // Device orientations
  static List<DeviceOrientation> get supportedOrientations =>
      <DeviceOrientation>[DeviceOrientation.portraitUp];

  // Initialize environment early (e.g., in main())
  static void setEnvironment(Environment env) {
    environment = env;
  }
}
