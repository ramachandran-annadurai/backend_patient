import '../services/core/network_request.dart';

class SaveSleepLogResponseModel extends NetworkResponse {
  final String message;
  final String patientEmail;
  final String patientId;
  final int sleepLogsCount;
  final bool success;

  SaveSleepLogResponseModel({
    required this.message,
    required this.patientEmail,
    required this.patientId,
    required this.sleepLogsCount,
    required this.success,
  }): super.fromJson({});

  factory SaveSleepLogResponseModel.fromJson(Map<String, dynamic> json) {
    return SaveSleepLogResponseModel(
      message: (json['message'] ?? '').toString(),
      patientEmail: (json['patientEmail'] ?? '').toString(),
      patientId: (json['patientId'] ?? '').toString(),
      sleepLogsCount: json['sleepLogsCount'] ?? 0,
      success: json['success'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'patientEmail': patientEmail,
      'patientId': patientId,
      'sleepLogsCount': sleepLogsCount,
      'success': success,
    };
  }

  @override
  String toString() {
    return 'SaveSleepLogResponseModel(message: $message, patientEmail: $patientEmail, patientId: $patientId, sleepLogsCount: $sleepLogsCount, success: $success)';
  }
}
