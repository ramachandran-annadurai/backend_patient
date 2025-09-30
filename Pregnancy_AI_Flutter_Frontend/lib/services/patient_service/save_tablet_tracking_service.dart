import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class SaveTabletTrackingService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(Map<String, dynamic> tabletData) async {
    try {
      print('🔍 Saving Tablet Tracking in medication_daily_tracking array:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/save-tablet-tracking');
      print('🔍 Data: $tabletData');
      final response = await post(
        '${ApiConfig.baseUrl}/medication/save-tablet-tracking',
        tabletData,
      );
      if (!response.containsKey('error')) {
        print('🔍 Tablet Tracking Saved Successfully in medication_daily_tracking array');
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
