import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetPrescriptionDetailsService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      print('🔍 Getting Prescription Details:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/get-prescription-details/$patientId');
      final response = await get(
        '${ApiConfig.baseUrl}/medication/get-prescription-details/$patientId',
      );
      if (!response.containsKey('error')) {
        print('🔍 Prescription Details Retrieved: ${response['totalPrescriptions']} prescriptions');
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
