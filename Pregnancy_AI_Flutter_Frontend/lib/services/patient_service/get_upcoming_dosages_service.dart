import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/get_upcoming_dosages_response.dart';

class GetUpcomingDosagesService extends ApiProvider {
  Future<GetUpcomingDosagesResponseModel> call(
      {required String patientId}) async {
    try {
      print('📅 Getting Upcoming Dosages:');
      print('🔍 Patient ID: $patientId');

      final endpoint =
          '${ApiConfig.baseUrl}/medication/get-upcoming-dosages/$patientId';

      print('🔍 Get Upcoming Dosages API Call:');
      print('🔍 URL: $endpoint');

      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.get,
        isTokenRequired: true, // Getting upcoming dosages requires auth token
      );

      final response = await makeAPICall(
        request,
        (json) => GetUpcomingDosagesResponseModel.fromJson(
            json as Map<String, dynamic>),
      );

      print('🔍 Get Upcoming Dosages Response: ${response.toJson()}');

      if (response.success == true) {
        final totalUpcoming = response.totalUpcoming;
        print('✅ Retrieved $totalUpcoming upcoming dosages');
        return response;
      }
      print('❌ Get upcoming dosages failed');
      return response;
    } on ErrorResponse catch (e) {
      print('❌ Get upcoming dosages error: ${e.error}');
      rethrow;
    } catch (e) {
      print('❌ Get upcoming dosages unexpected error: $e');
      throw ErrorResponse('Unexpected error getting upcoming dosages: $e');
    }
  }
}
