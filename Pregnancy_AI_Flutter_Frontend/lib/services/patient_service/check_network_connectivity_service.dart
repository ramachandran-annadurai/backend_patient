import 'package:http/http.dart' as http;
import '../core/base_api_provider.dart';

class CheckNetworkConnectivityService extends BaseApiProvider {
  Future<bool> call() async {
    try {
      print('🌐 Checking network connectivity...');
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final isConnected = response.statusCode == 200;
      print('🌐 Network connectivity: ${isConnected ? "✅ CONNECTED" : "❌ DISCONNECTED"}');
      return isConnected;
    } catch (e) {
      print('❌ Network connectivity check failed: $e');
      return false;
    }
  }
}
