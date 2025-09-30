import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/forgot_password_success_response.dart';

class ForgotPasswordService extends ApiProvider {
  Future<ForgotPasswordSuccessResponse> call({
    required String loginIdentifier,
  }) async {
    try {
      String endpoint =
          '${ApiConfig.baseUrl}${ApiConfig.forgotPasswordEndpoint}';
      Map<String, dynamic> requestBody = {
        'login_identifier': loginIdentifier,
      };

      print('🔍 Forgot Password API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Login Identifier: $loginIdentifier');

      // Use makeApiCall instead of post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: false, // Forgot password doesn't need auth token
      );

      final response = await makeAPICall(
        request,
        (json) => ForgotPasswordSuccessResponse.fromJson(
            json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed
      );

      print('🔍 Forgot Password Response: $response');
      return response;
    } on ErrorResponse catch (e) {
      print('❌ Forgot password error: ${e.error}');
      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print('❌ Forgot password unexpected error: $e');
      throw ErrorResponse('Unexpected forgot password error: $e');
    }
  }
}
