import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/signup_success_response.dart';

class SignupService extends ApiProvider {
  Future<SignupSuccessResponse> call({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String role,
    required bool isPregnant,
  }) async {
    try {
      String endpoint;
      Map<String, dynamic> requestBody;

      endpoint = '${ApiConfig.baseUrl}${ApiConfig.patientSignupEndpoint}';
      requestBody = {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
        'role': role,
        'is_pregnant': isPregnant,
      };
      print('🔍 Patient Signup API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Role: $role (using patient backend - patients_v2 collection)');
      // Use makeApiCall instead of post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: false, // Signup doesn't need auth token
      );

      final response = await makeAPICall(
        request,
        (json) => SignupSuccessResponse.fromJson(json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed
      );
      print(
          '🔍 ${role == 'doctor' ? 'Doctor' : 'Patient'} Signup Response: $response');
      return response;
    } on ErrorResponse catch (e) {
      // Handle specific 409 Resource Conflict errors
      if (e.error == 'USER_EXISTS') {
        print('⚠️ User already exists: ${e.error}');
        // Add any additional logging or processing for conflict errors
      } else {
        print(
            '❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} signup error: ${e.error}');
      }

      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print(
          '❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} signup unexpected error: $e');
      throw ErrorResponse('Unexpected signup error: $e');
    }
  }
}
