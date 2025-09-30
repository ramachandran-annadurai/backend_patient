import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/symptom_analysis_request.dart';
import '../../models/symptom_analysis_response.dart';

class SymptomAnalysisService extends ApiProvider {
  Future<SymptomAnalysisResponseModel> call(
      SymptomAnalysisRequestModel request) async {
    try {
      print('🏥 Analyzing symptom with AI:');
      print('🔍 Symptom: ${request.text}');
      print('🔍 Patient ID: ${request.patientId}');
      print('🔍 Pregnancy Week: ${request.weeksPregnant}');
      print('🔍 Severity: ${request.severity}');

      // Prepare request data
      final endpoint = '${ApiConfig.baseUrl}/symptoms/assist';
      final requestBody = request.toJson();

      print('🔍 Symptom Analysis API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Request Body: $requestBody');

      // Use makeApiCall
      final requestObj = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: true,
      );

      final response = await makeAPICall(
        requestObj,
        (json) =>
            SymptomAnalysisResponseModel.fromJson(json as Map<String, dynamic>),
      );

      print('🔍 Symptom Analysis Response: $response');

      if (response.success) {
        print('✅ Symptom analysis successful');
        return response;
      } else {
        print('❌ Symptom analysis failed');
        throw ErrorResponse('Symptom analysis failed');
      }
    } on ErrorResponse catch (e) {
      print('❌ Symptom analysis error: ${e.error}');
      rethrow;
    } catch (e) {
      print('❌ Symptom analysis unexpected error: $e');
      throw ErrorResponse('Unexpected analysis error: $e');
    }
  }
}
