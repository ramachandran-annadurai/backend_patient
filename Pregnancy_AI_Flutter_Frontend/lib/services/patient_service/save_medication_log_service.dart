import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/save_medication_log_request.dart';
import '../../models/save_medication_log_response.dart';

class SaveMedicationLogService extends ApiProvider {
  Future<SaveMedicationLogResponseModel> call(
      {required SaveMedicationLogRequest requestModel}) async {
    try {
      print('💊 Saving Medication Log:');
      print('🔍 Medication Name: ${requestModel.medicationName}');
      print('🔍 Dosages Count: ${requestModel.dosages.length}');
      print('🔍 Patient ID: ${requestModel.patientId}');
      print('🔍 Pregnancy Week: ${requestModel.pregnancyWeek}');

      final endpoint = '${ApiConfig.baseUrl}/medication/save-medication-log';

      print('🔍 Save Medication Log API Call:');
      print('🔍 URL: $endpoint');
      print('🔍 Request Body: ${requestModel.toJson()}');

      final request = NetworkRequest(
        path: endpoint,
        type: NetworkRequestType.post,
        body: requestModel.toJson(),
        isTokenRequired: true, // Saving medication log requires auth token
      );

      final response = await makeAPICall(
        request,
        (json) => SaveMedicationLogResponseModel.fromJson(
            json as Map<String, dynamic>),
      );

      print('🔍 Save Medication Log Response: ${response.toJson()}');

      if (response.success == true) {
        print('✅ Medication log saved successfully');
        return response;
      }
      print('❌ Medication log save failed: ${response.message}');
      return response;
    } on ErrorResponse catch (e) {
      print('❌ Save medication log error: ${e.error}');
      rethrow;
    } catch (e) {
      print('❌ Save medication log unexpected error: $e');
      throw ErrorResponse('Unexpected error saving medication log: $e');
    }
  }
}
