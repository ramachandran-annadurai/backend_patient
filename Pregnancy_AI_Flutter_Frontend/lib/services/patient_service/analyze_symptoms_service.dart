import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class AnalyzeSymptomsService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(Map<String, dynamic> symptomData) async {
    try {
      print('🔍 Symptom Analysis API Call:');
      print('🔍 URL: ${ApiConfig.baseUrl}/symptoms/assist');
      print('🔍 Data: $symptomData');
      final response = await post(
        '${ApiConfig.baseUrl}/symptoms/assist',
        symptomData,
      );
      print('🔍 Full Response: $response');
      if (!response.containsKey('error')) {
        print('🔍 Analysis Result: $response');
        return response;
      } else {
        print('❌ API Error: ${response['error']}');
        return response;
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return {'error': 'Network error: $e'};
    }
  }
}
