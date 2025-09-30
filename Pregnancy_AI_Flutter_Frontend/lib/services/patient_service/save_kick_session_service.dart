import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/kick_counter_request.dart';
import '../../models/kick_counter_response.dart';

class SaveKickSessionService extends ApiProvider {
  Future<KickCounterResponseModel> call(
      KickCounterRequestModel requestModel) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}/save-kick-session';

      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestModel.toJson(),
        isTokenRequired: true,
      );

      final response = await makeAPICall(
        request,
        (json) => KickCounterResponseModel.fromJson(json as Map<String, dynamic>),
       // removeTimeout: true,
      );

      return response;
    } on ErrorResponse {
      rethrow;
    } catch (e) {
      throw ErrorResponse('Unexpected kick session error: $e');
    }
  }
}
