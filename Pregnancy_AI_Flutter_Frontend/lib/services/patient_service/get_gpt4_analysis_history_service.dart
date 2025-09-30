import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetGPT4AnalysisHistoryService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String userId) async {
    try {
      print('🔍 Getting GPT-4 analysis history for user: $userId');
      final response = await get(
        '${ApiConfig.nutritionBaseUrl}/nutrition/get-food-entries/$userId',
      );
      if (!response.containsKey('error')) {
        print('✅ GPT-4 analysis history retrieved: ${response['total_entries'] ?? 0} entries');
      } else {
        print('❌ API Error: ${response['error']}');
      }
      return response;
    } catch (e) {
      print('❌ Network Error: $e');
      return {'error': 'Network error: $e'};
    }
  }
}
