import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetSymptomAnalysisReportsService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      print('🔍 Getting Symptom Analysis Reports:');
      print('🔍 URL: ${ApiConfig.baseUrl}/symptoms/get-analysis-reports/$patientId');
      final response = await get(
        '${ApiConfig.baseUrl}/symptoms/get-analysis-reports/$patientId',
      );
      print('🔍 Full Response: $response');
      if (!response.containsKey('error')) {
        print('🔍 Reports Retrieved: ${response['totalAnalysisReports']} reports');
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
