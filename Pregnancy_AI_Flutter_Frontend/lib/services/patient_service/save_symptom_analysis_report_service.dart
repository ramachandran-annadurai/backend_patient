import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class SaveSymptomAnalysisReportService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(Map<String, dynamic> reportData) async {
    try {
      print('🔍 Saving Symptom Analysis Report:');
      print('🔍 URL: ${ApiConfig.baseUrl}/symptoms/save-analysis-report');
      print('🔍 Data: $reportData');
      final response = await post(
        '${ApiConfig.baseUrl}/symptoms/save-analysis-report',
        reportData,
      );
      print('🔍 Full Response: $response');
      if (!response.containsKey('error')) {
        print('🔍 Report Saved Successfully: $response');
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
