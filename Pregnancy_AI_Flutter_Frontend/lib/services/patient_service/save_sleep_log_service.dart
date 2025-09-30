import '../../models/kick_counter_response.dart';
import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/sleep_log.dart';
import '../../models/save_sleep_log_response.dart';

class SaveSleepLogService extends ApiProvider {
  Future<SaveSleepLogResponseModel> call(SleepLogModel sleepLog) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/save-sleep-log';
      final requestBody = sleepLog.toJson();

      print('🔍 Sleep Log API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Sleep Data: ${sleepLog.toJson()}');

      // Use makeApiCall instead of post
      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: true, // Sleep log requires auth token
      );

      final response = await makeAPICall(
        request,
        (json) => SaveSleepLogResponseModel.fromJson(json as Map<String, dynamic>),
        //removeTimeout: true, // ✅ No timeout - wait as long as needed
      );

      print('🔍 Sleep Log Response: $response');

      // Convert response to SaveSleepLogResponseModel
      return response;
    } on ErrorResponse catch (e) {
      print('❌ Sleep log error: ${e.error}');
      // Re-throw ErrorResponse for repository/provider to handle
      rethrow;
    } catch (e) {
      // Handle any unexpected errors
      print('❌ Sleep log unexpected error: $e');
      throw ErrorResponse('Unexpected sleep log error: $e');
    }
  }
}
