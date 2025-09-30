import 'dart:convert';
import 'package:http/http.dart' as http;
// No ApiCore needed here; uses direct multipart request
import '../../utils/constants.dart';

class ProcessPrescriptionDocumentService {
  Future<Map<String, dynamic>> call(
    String patientId,
    String medicationName,
    List<int> fileBytes,
    String filename,
  ) async {
    try {
      print('🔍 Processing Prescription Document with OCR:');
      print('🔍 URL: ${ApiConfig.baseUrl}/medication/process-prescription-document');
      print('🔍 Patient ID: $patientId');
      print('🔍 Medication Name: $medicationName');
      print('🔍 Filename: $filename');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/medication/process-prescription-document'),
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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('🔍 OCR Document Processing Successful: $result');
        return result;
      } else {
        print('❌ OCR API Error: ${response.statusCode} - ${response.body}');
        return {'error': 'OCR API Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ OCR Network Error: $e');
      return {'error': 'OCR Network error: $e'};
    }
  }
}
