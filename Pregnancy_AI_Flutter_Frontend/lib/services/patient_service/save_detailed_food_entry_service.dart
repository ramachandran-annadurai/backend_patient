import '../../utils/constants.dart';
import '../core/api_core.dart';
import '../core/network_request.dart';
import '../../models/save_food_entry_response.dart';

class SaveDetailedFoodEntryService extends ApiProvider {
  Future<SaveFoodEntryResponseModel> call(Map<String, dynamic> data) async {
    try {
      final request = NetworkRequest(
        path: '${ApiConfig.nutritionBaseUrl}/nutrition/save-food-entry',
        type: NetworkRequestType.post,
        body: data,
        isTokenRequired: true,
      );

      final response = await makeAPICall(
        request,
        (json) =>
            SaveFoodEntryResponseModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success) {
        return response;
      }

      print('Error saving food entry: ${response.message}');

      throw ErrorResponse(response.message);
    } on ErrorResponse {
      rethrow;
    } catch (e) {
      throw ErrorResponse('Unexpected save error: $e');
    }
  }
}
