import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/otp_model.dart';
import '../../models/otp_verification_success_response.dart';

class VerifyOtpService extends ApiProvider {
  Future<OtpVerificationSuccessResponse> call(OtpModel otpModel,
      {required String role}) async {
    try {
      String endpoint;
      Map<String, dynamic> requestBody;

      endpoint = '${ApiConfig.baseUrl}${ApiConfig.patientVerifyOtpEndpoint}';
      requestBody = otpModel.toJson(); // Add role for patient endpoint
      print('🔍 Patient OTP Verification API Call:');
      print('🔍 URL: $endpoint');
      print(
          '🔍 Email: ${otpModel.email} (using patient backend - patients_v2 collection)');
      print(requestBody);

      // Use makeApiCall instead of post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: false, // OTP verification doesn't need auth token
      );

      final response = await makeAPICall(
        request,
        (json) => OtpVerificationSuccessResponse.fromJson(
            json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed
      );
      print(
          '🔍 ${role == 'doctor' ? 'Doctor' : 'Patient'} OTP Verification Response: $response');
      return response;
    } on ErrorResponse catch (e) {
      // Handle specific OTP verification errors
      if (e.error == 'INVALID_OTP') {
        print('⚠️ Invalid OTP: ${e.error}');
      } else if (e.error== 'OTP_EXPIRED') {
        print('⚠️ OTP expired: ${e.error}');
      } else {
        print(
            '❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} OTP verification error: ${e.error}');
      }

      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print(
          '❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} OTP verification unexpected error: $e');
      throw ErrorResponse('Unexpected OTP verification error: $e');
    }
  }
}
