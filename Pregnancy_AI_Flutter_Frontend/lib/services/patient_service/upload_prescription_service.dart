import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class UploadPrescriptionService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(Map<String, dynamic> prescriptionData) async {
    try {
      print('🔍 Uploading Prescription:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/upload-prescription');
      print('🔍 Data: $prescriptionData');
      final response = await post(
        '${ApiConfig.baseUrl}/medication/upload-prescription',
        prescriptionData,
      );
      if (!response.containsKey('error')) {
        print('🔍 Prescription Uploaded Successfully');
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
