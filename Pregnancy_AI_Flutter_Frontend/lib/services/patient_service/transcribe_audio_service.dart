import 'dart:convert';
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class TranscribeAudioService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String audioBase64, {String language = 'auto'}) async {
    try {
      print('🎤 Transcribing audio with language: $language');
      final response = await post(
        '${ApiConfig.nutritionBaseUrl}/nutrition/transcribe',
        {
          'audio': audioBase64,
          'language': language,
          'method': 'whisper'
        },
      );
      if (!response.containsKey('error')) {
        print('✅ Audio transcription successful: ${response['success']}');
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
