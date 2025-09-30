import 'process_prescription_document_service.dart';
import 'process_prescription_with_n8n_service.dart';

class ProcessPrescriptionWithOCRAndN8NService {
  final ProcessPrescriptionDocumentService _docService = ProcessPrescriptionDocumentService();
  final ProcessPrescriptionWithN8NService _n8nService = ProcessPrescriptionWithN8NService();

  Future<Map<String, dynamic>> call({
    required String patientId,
    required String medicationName,
    required String filename,
    required String extractedText,
  }) async {
    try {
      print('🔍 Processing prescription with OCR and N8N webhook...');

      final ocrResult = await _docService.call(patientId, medicationName, [], filename);

      if (!ocrResult['success']) {
        return ocrResult;
      }

      final n8nResult = await _n8nService.call({
        'patient_id': patientId,
        'medication_name': medicationName,
        'extracted_text': extractedText,
        'filename': filename,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Prescription processed successfully with OCR and N8N',
        'ocr_result': ocrResult,
        'n8n_result': n8nResult,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error in processPrescriptionWithOCRAndN8N: $e');
      return {
        'success': false,
        'message': 'Error processing prescription: $e',
        'error': e.toString(),
      };
    }
  }
}
