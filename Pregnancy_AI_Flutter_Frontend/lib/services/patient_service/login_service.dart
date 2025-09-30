import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../utils/constants.dart';
import '../../models/login_model.dart';

class LoginService extends ApiProvider {
  Future<LoginResponseModel> call({
    required String loginIdentifier,
    required String password,
  }) async {
    try {
      final endpoint = '${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}';
      final requestBody = {
        'login_identifier': loginIdentifier,
        'password': password,
      };

      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestBody,
        isTokenRequired: false,
      );

      final response = await makeAPICall(
        request,
        (json) => LoginResponseModel.fromJson(json as Map<String, dynamic>),
        //removeTimeout: true,
      );

      return response;
    } on ErrorResponse {
      rethrow;
    } catch (e) {
      throw ErrorResponse('Unexpected login error: $e');
    }
  }
}
