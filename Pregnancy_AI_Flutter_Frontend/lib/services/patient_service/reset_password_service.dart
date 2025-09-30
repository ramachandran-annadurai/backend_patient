import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/reset_password_success_response.dart';

class ResetPasswordService extends ApiProvider {
  Future<ResetPasswordSuccessResponse> call({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}${ApiConfig.resetPasswordEndpoint}';
      final requestBody = {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      };

      print('🔍 Reset Password API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Email: $email');

      // Use makeApiCall instead of post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: false, // Reset password doesn't need auth token
      );

      final response = await makeAPICall(
        request,
        (json) =>
            ResetPasswordSuccessResponse.fromJson(json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed
      );

      print('🔍 Reset Password Response: $response');
      return response;
    } on ErrorResponse catch (e) {
      // Handle specific error responses
      print('❌ Reset password error: ${e.error}');

      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print('❌ Reset password unexpected error: $e');
      throw ErrorResponse('Unexpected reset password error: $e');
    }
  }
}
