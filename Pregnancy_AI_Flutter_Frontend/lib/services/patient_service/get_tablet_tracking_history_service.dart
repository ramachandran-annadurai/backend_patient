import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetTabletTrackingHistoryService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      print('🔍 Getting Tablet Tracking History from medication_daily_tracking array:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/get-tablet-tracking-history/$patientId');
      final response = await get(
        '${ApiConfig.baseUrl}/medication/get-tablet-tracking-history/$patientId',
      );
      if (!response.containsKey('error')) {
        print('🔍 Tablet Tracking History Retrieved from medication_daily_tracking array: ${response['totalEntries'] ?? 0} entries');
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
