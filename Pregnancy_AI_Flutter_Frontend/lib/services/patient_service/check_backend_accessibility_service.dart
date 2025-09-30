import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class CheckBackendAccessibilityService extends BaseApiProvider {
  Future<bool> call() async {
    try {
      print('🔍 Checking backend accessibility...');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: const {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      final isAccessible = response.statusCode == 200;
      print('🔍 Backend accessibility: ${isAccessible ? "✅ ACCESSIBLE" : "❌ NOT ACCESSIBLE"}');
      return isAccessible;
    } catch (e) {
      print('❌ Backend accessibility check failed: $e');
      return false;
    }
  }
}
