import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class ProcessDocumentWithPaddleOCRService {
  Future<Map<String, dynamic>> call({
    required String patientId,
    required String medicationName,
    required String filename,
    required List<int> fileBytes,
  }) async {
    try {
      print('🚀 Processing document with PaddleOCR for full text extraction...');
      print('🔍 File size: ${fileBytes.length} bytes');
      print('🔍 Filename: $filename');
      print('🔍 Patient ID: $patientId');
      print('🔍 Medication: $medicationName');
      print('🔍 Target URL: ${ApiConfig.baseUrl}/medication/process-with-paddleocr');

      if (fileBytes.length > 10 * 1024 * 1024) {
        return {
          'success': false,
          'message': 'File too large. Maximum size is 10MB.',
          'error': 'File size: ${fileBytes.length} bytes exceeds 10MB limit',
        };
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/medication/process-with-paddleocr'),
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

      http.StreamedResponse? streamedResponse;
      int retryCount = 0;
      const int maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          print('🔄 Attempt ${retryCount + 1} of $maxRetries...');
          streamedResponse = await request.send().timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('File upload timed out after 60 seconds');
            },
          );
          print('📥 Received response stream, status: ${streamedResponse.statusCode}');
          break;
        } on TimeoutException catch (e) {
          retryCount++;
          print('⏰ Timeout on attempt $retryCount: $e');
          if (retryCount >= maxRetries) {
            return {
              'success': false,
              'message': 'File upload timed out after multiple attempts. The server might be busy.',
              'error': e.toString(),
            };
          }
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        } catch (e) {
          retryCount++;
          print('❌ Error on attempt $retryCount: $e');
          if (retryCount >= maxRetries) {
            return {
              'success': false,
              'message': 'File upload failed after multiple attempts.',
              'error': e.toString(),
            };
          }
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
      }

      if (streamedResponse == null) {
        return {
          'success': false,
          'message': 'Failed to get response from server after all retry attempts.',
          'error': 'No response received',
        };
      }

      final response = await http.Response.fromStream(streamedResponse);
      print('📄 Response status: ${response.statusCode}');
      print('📄 Response headers: ${response.headers}');
      print('📄 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          print('✅ PaddleOCR processing successful');
          print('🔍 Full text content length: ${result['full_text_content']?.toString().length ?? 0}');
          print('🔍 Response keys: ${result.keys.toList()}');
          return result;
        } catch (e) {
          print('❌ Error parsing JSON response: $e');
          return {
            'success': false,
            'message': 'Server returned invalid JSON response.',
            'error': 'JSON parsing error: $e',
            'raw_response': response.body,
          };
        }
      } else {
        print('❌ PaddleOCR processing error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return {
          'success': false,
          'error': 'PaddleOCR processing error: ${response.statusCode}',
          'response_body': response.body,
          'status_code': response.statusCode,
        };
      }
    } on TimeoutException catch (e) {
      print('❌ Timeout error in PaddleOCR processing: $e');
      return {
        'success': false,
        'message': 'File upload timed out. The file might be too large or the server is busy.',
        'error': e.toString(),
      };
    } on http.ClientException catch (e) {
      print('❌ Client exception in PaddleOCR processing: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
        'error': e.toString(),
      };
    } catch (e) {
      print('❌ Unexpected error in PaddleOCR processing: $e');
      return {
        'success': false,
        'message': 'Unexpected error occurred while processing the file.',
        'error': e.toString(),
      };
    }
  }
}
