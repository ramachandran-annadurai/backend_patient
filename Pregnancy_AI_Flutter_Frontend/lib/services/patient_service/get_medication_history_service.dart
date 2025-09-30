import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetMedicationHistoryService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      print('🔍 Getting Medication History:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/get-medication-history/$patientId');
      final response = await get(
        '${ApiConfig.baseUrl}/medication/get-medication-history/$patientId',
      );
      if (!response.containsKey('error')) {
        print('🔍 Medication History Retrieved: ${response['totalEntries']} entries');
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
