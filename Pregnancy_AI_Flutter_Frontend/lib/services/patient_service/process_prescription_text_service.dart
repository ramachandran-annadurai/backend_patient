import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class ProcessPrescriptionTextService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(
    String patientId,
    String prescriptionText,
  ) async {
    try {
      print('🔍 Processing Prescription Text:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/process-prescription-text');
      print('🔍 Patient ID: $patientId');
      print('🔍 Text Length: ${prescriptionText.length}');
      final response = await post(
        '${ApiConfig.baseUrl}/medication/process-prescription-text',
        {
          'patient_id': patientId,
          'text': prescriptionText,
        },
      );
      if (!response.containsKey('error')) {
        print('🔍 Prescription Text Processing Successful');
      } else {
        print('❌ Text Processing API Error: ${response['error']}');
      }
      return response;
    } catch (e) {
      print('❌ Text Processing Network Error: $e');
      return {'error': 'Text Processing Network error: $e'};
    }
  }
}
