import '../services/patient_service/save_medication_log_service.dart';
import '../services/patient_service/get_medication_history_service.dart';
import '../services/patient_service/get_upcoming_dosages_service.dart';
import '../services/patient_service/save_tablet_taken_service.dart';
import '../services/patient_service/save_tablet_tracking_service.dart';
import '../services/patient_service/get_tablet_tracking_history_service.dart';
import '../services/patient_service/get_tablet_history_service.dart';
import '../services/patient_service/upload_prescription_service.dart';
import '../services/patient_service/get_prescription_details_service.dart';
import '../services/patient_service/update_prescription_status_service.dart';
import '../services/patient_service/process_prescription_text_service.dart';
import '../services/patient_service/process_prescription_with_medication_webhook_service.dart';
import '../models/medication.dart';
import '../models/save_medication_log_request.dart';
import '../models/save_medication_log_response.dart';
import '../models/get_upcoming_dosages_response.dart';

class MedicationRepository {
  final SaveMedicationLogService _saveLog = SaveMedicationLogService();
  final GetMedicationHistoryService _getHistory = GetMedicationHistoryService();
  final GetUpcomingDosagesService _getUpcoming = GetUpcomingDosagesService();
  final SaveTabletTakenService _saveTabletTaken = SaveTabletTakenService();
  final SaveTabletTrackingService _saveTabletTracking =
      SaveTabletTrackingService();
  final GetTabletTrackingHistoryService _getTabletTracking =
      GetTabletTrackingHistoryService();
  final GetTabletHistoryService _getTabletHistory = GetTabletHistoryService();
  final UploadPrescriptionService _uploadPrescription =
      UploadPrescriptionService();
  final GetPrescriptionDetailsService _getPrescriptionDetails =
      GetPrescriptionDetailsService();
  final UpdatePrescriptionStatusService _updatePrescriptionStatus =
      UpdatePrescriptionStatusService();
  final ProcessPrescriptionTextService _processText =
      ProcessPrescriptionTextService();
  final ProcessPrescriptionWithMedicationWebhookService _processWebhook =
      ProcessPrescriptionWithMedicationWebhookService();

  Future<SaveMedicationLogResponseModel> saveMedicationLog(
          SaveMedicationLogRequest request) =>
      _saveLog.call(requestModel: request);

  Future<Map<String, dynamic>> getMedicationHistory(String patientId) =>
      _getHistory.call(patientId);

  Future<List<MedicationLogModel>> getMedicationHistoryAsModels(
      String patientId) async {
    final res = await _getHistory.call(patientId);
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final list =
        (res['items'] ?? res['entries'] ?? res['history'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => MedicationLogModel.fromJson(e))
        .toList();
  }

  Future<GetUpcomingDosagesResponseModel> getUpcomingDosages(
          String patientId) =>
      _getUpcoming.call(patientId: patientId);

  //tablet related

  //Future<Map<String, dynamic>> saveTabletTaken(Map<String, dynamic> data) => _saveTabletTaken.call(data);
  Future<Map<String, dynamic>> saveTabletTracking(Map<String, dynamic> data) =>
      _saveTabletTracking.call(data);
  Future<Map<String, dynamic>> getTabletTrackingHistory(String patientId) =>
      _getTabletTracking.call(patientId);

  Future<List<TabletTrackingEntryModel>> getTabletTrackingHistoryAsModels(
      String patientId) async {
    final res = await _getTabletTracking.call(patientId);
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final list =
        (res['entries'] ?? res['items'] ?? res['history'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => TabletTrackingEntryModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> getTabletHistory(String patientId) =>
      _getTabletHistory.call(patientId);

  Future<List<TabletTrackingEntryModel>> getTabletHistoryAsModels(
      String patientId) async {
    final res = await _getTabletHistory.call(patientId);
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final list =
        (res['entries'] ?? res['items'] ?? res['history'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => TabletTrackingEntryModel.fromJson(e))
        .toList();
  }

  // Upload prescription and get response

  Future<Map<String, dynamic>> uploadPrescription(Map<String, dynamic> data) =>
      _uploadPrescription.call(data);
  Future<Map<String, dynamic>> getPrescriptionDetails(String patientId) =>
      _getPrescriptionDetails.call(patientId);

  Future<List<PrescriptionModel>> getPrescriptionDetailsAsModels(
      String patientId) async {
    final res = await _getPrescriptionDetails.call(patientId);
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final list =
        (res['prescriptions'] ?? res['items'] ?? res['data'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PrescriptionModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> updatePrescriptionStatus(
          String patientId, String prescriptionId, String status) =>
      _updatePrescriptionStatus.call(patientId, prescriptionId, status);
  Future<Map<String, dynamic>> processPrescriptionText(
          String patientId, String text) =>
      _processText.call(patientId, text);
  Future<Map<String, dynamic>> processPrescriptionWithWebhook({
    required String patientId,
    required String medicationName,
    required String filename,
    required String extractedText,
  }) =>
      _processWebhook.call(
          patientId: patientId,
          medicationName: medicationName,
          filename: filename,
          extractedText: extractedText);
}
