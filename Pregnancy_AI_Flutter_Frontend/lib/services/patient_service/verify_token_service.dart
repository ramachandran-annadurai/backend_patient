import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class VerifyTokenService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String token,
  }) async {
    try {
      final response = await post(
        '${ApiConfig.baseUrl}/verify-token',
        {
          'token': token,
        },
      );
      return response;
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}
