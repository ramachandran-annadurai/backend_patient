import '../../models/patient_profile_response.dart';
import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';

class GetProfileService extends ApiProvider {
  Future<PatientProfileResponse> call({
    required String patientId,
  }) async {
    try {
      final request = NetworkRequest(
        path: '${ApiConfig.baseUrl}${ApiConfig.getProfileEndpoint}/$patientId',
        type: NetworkRequestType.get,
        isTokenRequired: true,
      );
      return await makeAPICall(
        request,
        (json) => PatientProfileResponse.fromJson(json as Map<String, dynamic>),
      );
    } on ErrorResponse catch (e) {
      print('❌ Get Profile error: ${e.error}');
      rethrow; // Let ProfileRepository handle ErrorResponse
    } catch (e) {
      print('❌ Get Profile unexpected error: $e');
      throw ErrorResponse('Failed to get profile: $e');
    }
  }
}
