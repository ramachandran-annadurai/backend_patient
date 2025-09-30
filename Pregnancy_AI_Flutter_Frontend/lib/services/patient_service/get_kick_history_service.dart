import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class GetKickHistoryService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String patientId) async {
    try {
      final response = await get(
        '${ApiConfig.baseUrl}/get-kick-history/$patientId',
      );
      if (!response.containsKey('error')) {
        return response;
      }
      throw Exception('Failed to get kick history');
    } catch (e) {
      throw Exception('Error getting kick history: $e');
    }
  }
}
