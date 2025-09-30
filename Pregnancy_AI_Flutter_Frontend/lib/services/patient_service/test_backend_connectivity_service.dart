import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class TestBackendConnectivityService extends BaseApiProvider {
  Future<Map<String, dynamic>> call() async {
    final urls = ApiConfig.getAlternativeUrls();
    final results = <String, bool>{};

    print('🔍 Testing backend connectivity...');

    for (final url in urls) {
      try {
        print('📡 Testing: $url');
        final response = await http.get(
          Uri.parse('$url/medication/test-status'),
          headers: const {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          results[url] = true;
          print('✅ $url - CONNECTED');
        } else {
          results[url] = false;
          print('❌ $url - HTTP ${response.statusCode}');
        }
      } catch (e) {
        results[url] = false;
        print('❌ $url - ERROR: $e');
      }
    }

    String? bestUrl;
    for (final entry in results.entries) {
      if (entry.value == true) {
        bestUrl = entry.key;
        break;
      }
    }

    return {
      'success': bestUrl != null,
      'best_url': bestUrl,
      'all_results': results,
      'recommendation': bestUrl != null
          ? 'Use: $bestUrl'
          : 'No backend URLs are accessible. Check if Flask server is running.',
    };
  }
}
