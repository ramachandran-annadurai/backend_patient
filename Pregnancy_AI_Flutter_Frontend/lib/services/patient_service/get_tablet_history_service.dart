import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetTabletHistoryService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      print('🔍 Getting Tablet History:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/get-tablet-history/$patientId');
      final response = await get(
        '${ApiConfig.baseUrl}/medication/get-tablet-history/$patientId',
      );
      if (!response.containsKey('error')) {
        print('🔍 Tablet History Retrieved: ${response['totalEntries']} entries');
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
