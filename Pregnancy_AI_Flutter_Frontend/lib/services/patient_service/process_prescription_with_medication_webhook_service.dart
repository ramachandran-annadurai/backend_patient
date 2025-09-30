import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class ProcessPrescriptionWithMedicationWebhookService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String patientId,
    required String medicationName,
    required String filename,
    required String extractedText,
  }) async {
    try {
      print('🚀 Processing prescription with medication folder webhook service...');
      final response = await post(
        '${ApiConfig.baseUrl}/medication/process-with-n8n-webhook',
        {
          'patient_id': patientId,
          'medication_name': medicationName,
          'extracted_text': extractedText,
          'filename': filename,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (!response.containsKey('error')) {
        print('✅ Medication webhook service processing successful');
      } else {
        print('❌ Medication webhook service error: ${response['error']}');
      }
      return response;
    } catch (e) {
      print('❌ Error in medication webhook service: $e');
      return {
        'success': false,
        'message': 'Error processing with medication webhook service: $e',
        'error': e.toString(),
      };
    }
  }
}
