import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class TestFileUploadService {
  Future<Map<String, dynamic>> call({
    required String patientId,
    required String medicationName,
    required String filename,
    required List<int> fileBytes,
  }) async {
    try {
      print('🧪 Testing file upload endpoint...');
      print('🔍 File size: ${fileBytes.length} bytes');
      print('🔍 Filename: $filename');
      print('🔍 Patient ID: $patientId');
      print('🔍 Medication: $medicationName');
      print('🔍 Target URL: ${ApiConfig.baseUrl}/medication/test-file-upload');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/medication/test-file-upload'),
      );

      request.fields['patient_id'] = patientId;
      request.fields['medication_name'] = medicationName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      print('📤 Sending test multipart request...');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('File upload test timed out after 15 seconds');
        },
      );

      print('📥 Received test response, status: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);

      print('📄 Test response status: ${response.statusCode}');
      print('📄 Test response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ File upload test successful');
        return result;
      } else {
        print('❌ File upload test failed: ${response.statusCode}');
        return {
          'success': false,
          'error': 'File upload test failed: ${response.statusCode}',
          'response_body': response.body,
        };
      }
    } on TimeoutException catch (e) {
      print('❌ Timeout error in file upload test: $e');
      return {
        'success': false,
        'message': 'File upload test timed out.',
        'error': e.toString(),
      };
    } on http.ClientException catch (e) {
      print('❌ Client exception in file upload test: $e');
      return {
        'success': false,
        'message': 'Network error during file upload test.',
        'error': e.toString(),
      };
    } catch (e) {
      print('❌ Unexpected error in file upload test: $e');
      return {
        'success': false,
        'message': 'Unexpected error during file upload test.',
        'error': e.toString(),
      };
    }
  }
}
