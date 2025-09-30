import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class ResendOtpService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String email,
    required String role,
  }) async {
    try {
      String endpoint;
      Map<String, dynamic> requestBody;
      endpoint = '${ApiConfig.baseUrl}${ApiConfig.sendOtpEndpoint}';
      requestBody = {
        'email': email,
        'role': role,
      };
      print('🔍 Patient Resend OTP API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Email: $email (using patient backend - patients_v2 collection)');

      final response = await post(endpoint, requestBody);
      return response;
    } catch (e) {
      print('❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} resend OTP network error: $e');
      return {'error': 'Network error: $e'};
    }
  }
}
