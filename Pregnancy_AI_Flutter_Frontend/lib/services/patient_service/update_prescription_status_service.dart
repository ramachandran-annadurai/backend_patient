import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class UpdatePrescriptionStatusService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId, String prescriptionId, String status) async {
    try {
      print('🔍 Updating Prescription Status:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/update-prescription-status/$patientId/$prescriptionId');
      print('🔍 Status: $status');
      final response = await put(
        '${ApiConfig.baseUrl}/medication/update-prescription-status/$patientId/$prescriptionId',
        {'status': status},
      );
      if (!response.containsKey('error')) {
        print('🔍 Prescription Status Updated Successfully');
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
