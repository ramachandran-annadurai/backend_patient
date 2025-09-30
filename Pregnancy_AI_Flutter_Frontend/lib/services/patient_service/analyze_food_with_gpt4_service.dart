import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/analyze_food_request.dart';
import '../../models/analyze_food_response.dart';

class AnalyzeFoodWithGPT4Service extends ApiProvider{
  Future<AnalyzeFoodResponseModel> call(
      AnalyzeFoodRequestModel requestModel) async {
    try {
      print('🍎 Analyzing food with GPT-4:');
      print('🔍 Food input: ${requestModel.foodInput}');
      print('🔍 Pregnancy week: ${requestModel.pregnancyWeek}');
      print('🔍 User ID: ${requestModel.userId}');

      // Prepare request data
      final endpoint =
          '${ApiConfig.nutritionBaseUrl}/nutrition/analyze-with-gpt4';
      final requestBody = requestModel.toJson();

      print('🔍 GPT-4 Analysis API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Request Body: $requestBody');

      // Health check first
      /*try {
        final healthRequest = NetworkRequest(
          path: '${ApiConfig.nutritionBaseUrl}/nutrition/health',
          type: NetworkRequestType.get,
          isTokenRequired: false,
        );

        final health = await makeAPICall(
          healthRequest,
          (json) => json as Map<String, dynamic>,
        );
        print('✅ Backend health check passed: ${health['status'] ?? 200}');
      } catch (e) {
        print('❌ Backend health check failed: $e');
        throw ErrorResponse('Backend not accessible: $e');
      }*/

      // Use makeApiCall instead of direct post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: true, // Analysis requires auth token
      );

      final response = await makeAPICall(
        request,
        (json) =>
            AnalyzeFoodResponseModel.fromJson(json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed for GPT-4
      );

      print('🔍 GPT-4 Analysis Response: $response');

      if (response.success) {
        print('✅ GPT-4 analysis successful');
        return response;
      } else {
        print('❌ GPT-4 analysis failed: ${response.analysis.note}');
        throw ErrorResponse(response.analysis.note);
      }
    } on ErrorResponse catch (e) {
      print('❌ GPT-4 analysis error: ${e.error}');
      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print('❌ GPT-4 analysis unexpected error: $e');
      throw ErrorResponse('Unexpected analysis error: $e');
    }
  }
}
