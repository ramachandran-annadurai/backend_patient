import '../services/core/network_request.dart';

class KickCounterResponseModel extends NetworkResponse {
  final int kickSessionsCount;
  final String message;
  final String patientEmail;
  final String patientId;
  final bool success;

  KickCounterResponseModel({
    required this.kickSessionsCount,
    required this.message,
    required this.patientEmail,
    required this.patientId,
    required this.success,
  }): super.fromJson({});

  factory KickCounterResponseModel.fromJson(Map<String, dynamic> json) {
    return KickCounterResponseModel(
      kickSessionsCount: json['kickSessionsCount'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown message',
      patientEmail: json['patientEmail'] as String? ?? 'N/A',
      patientId: json['patientId'] as String? ?? 'N/A',
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kickSessionsCount': kickSessionsCount,
      'message': message,
      'patientEmail': patientEmail,
      'patientId': patientId,
      'success': success,
    };
  }

  @override
  String toString() {
    return 'KickCounterResponseModel(kickSessionsCount: $kickSessionsCount, message: $message, patientEmail: $patientEmail, patientId: $patientId, success: $success)';
  }
}
