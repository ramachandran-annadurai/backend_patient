import '../services/core/network_request.dart';

/// Response model for Save Medication Log API
class SaveMedicationLogResponseModel extends NetworkResponse {
  final bool success;
  final String message;
  final String patientId;
  final String patientEmail;
  final int medicationLogsCount;
  final String timestamp; // ISO timestamp

  SaveMedicationLogResponseModel({
    required this.success,
    required this.message,
    required this.patientId,
    required this.patientEmail,
    required this.medicationLogsCount,
    required this.timestamp,
  }) : super.fromJson({});

  @override
  factory SaveMedicationLogResponseModel.fromJson(Map<String, dynamic> json) {
    return SaveMedicationLogResponseModel(
      success: (json['success'] ?? false) == true,
      message: (json['message'] ?? '').toString(),
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      patientEmail: (json['patientEmail'] ?? '').toString(),
      medicationLogsCount:
          int.tryParse(json['medicationLogsCount']?.toString() ?? '0') ?? 0,
      timestamp: (json['timestamp'] ?? '').toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'patientId': patientId,
      'patientEmail': patientEmail,
      'medicationLogsCount': medicationLogsCount,
      'timestamp': timestamp,
    };
  }
}
