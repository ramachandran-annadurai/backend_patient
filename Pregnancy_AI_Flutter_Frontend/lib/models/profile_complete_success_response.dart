import '../services/core/network_request.dart';
class ProfileCompleteSuccessResponse extends NetworkResponse {
  final bool isProfileComplete;
  final String message;
  final String patientId;

  ProfileCompleteSuccessResponse({
    required this.isProfileComplete,
    required this.message,
    required this.patientId,
  }) : super.fromJson({});

  factory ProfileCompleteSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ProfileCompleteSuccessResponse(
      isProfileComplete: json['is_profile_complete'] ?? false,
      message: json['message'] ?? '',
      patientId: json['patient_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_profile_complete': isProfileComplete,
      'message': message,
      'patient_id': patientId,
    };
  }
}
