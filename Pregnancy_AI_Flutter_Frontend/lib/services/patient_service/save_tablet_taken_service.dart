import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class SaveTabletTakenService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(Map<String, dynamic> tabletData) async {
    try {
      print('🔍 Saving Tablet Taken:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/save-tablet-taken');
      print('🔍 Data: $tabletData');
      final response = await post(
        '${ApiConfig.baseUrl}/medication/save-tablet-taken',
        tabletData,
      );
      if (!response.containsKey('error')) {
        print('🔍 Tablet Taken Saved Successfully: $response');
      } else {
        print('❌ API Error: ${response['error']}');
      }
      return response;
    } catch (e) {
      print('❌ Network Error: $e');
      return {'error': 'Network error: $e'};
    }
  }
}
