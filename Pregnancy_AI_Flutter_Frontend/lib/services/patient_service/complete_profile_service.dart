import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/profile_complete_success_response.dart';

class CompleteProfileService extends ApiProvider {
  Future<ProfileCompleteSuccessResponse> call({
    required String patientId,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String bloodType,
    required String weight,
    required String height,
    required bool isPregnant,
    String? lastPeriodDate,
    String? pregnancyWeek,
    String? expectedDeliveryDate,
    required String emergencyName,
    required String emergencyRelationship,
    required String emergencyPhone,
  }) async {
    try {
      final request = NetworkRequest(
        path: '${ApiConfig.baseUrl}${ApiConfig.completeProfileEndpoint}',
        type: NetworkRequestType.post,
        body: {
          'first_name': firstName,
          'last_name': lastName,
          'date_of_birth': dateOfBirth,
          'blood_type': bloodType,
          'weight': weight,
          'height': height,
          'is_pregnant': isPregnant,
          'last_period_date': lastPeriodDate,
          'pregnancy_week': pregnancyWeek,
          'expected_delivery_date': expectedDeliveryDate,
          'emergency_name': emergencyName,
          'emergency_relationship': emergencyRelationship,
          'emergency_phone': emergencyPhone,
        },
        isTokenRequired: true,
      );

      final response = await makeAPICall<ProfileCompleteSuccessResponse>(
        request,
        (json) => ProfileCompleteSuccessResponse.fromJson(
            json as Map<String, dynamic>),
        //removeTimeout: true, // No timeout for profile completion
      );
      print('🔍 Complete Profile Response: $response');
      return response;
    } on ErrorResponse catch (e) {
      print('❌ Complete Profile error: ${e.error}');
      rethrow; // Let ProfileProvider handle ErrorResponse
    } catch (e) {
      print('❌ Complete Profile unexpected error: $e');
      throw ErrorResponse('Profile completion failed: $e');
    }
  }
}
