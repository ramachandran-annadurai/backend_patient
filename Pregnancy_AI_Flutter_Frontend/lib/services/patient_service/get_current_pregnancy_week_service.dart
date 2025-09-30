import '../core/base_api_provider.dart';
import '../../utils/constants.dart';

class GetCurrentPregnancyWeekService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String userId) async {
    try {
      final res = await get(
        '${ApiConfig.nutritionBaseUrl}/get-current-pregnancy-week/$userId',
        auth: false,
      );
      print(res);
      return res;
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}


