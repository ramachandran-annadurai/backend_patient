import '../services/core/network_request.dart';

class ResetPasswordSuccessResponse extends NetworkResponse {
  final String email;
  final String message;
  final String mobile;
  final String patientId;
  final String status;
  final String username;

  ResetPasswordSuccessResponse({
    required this.email,
    required this.message,
    required this.mobile,
    required this.patientId,
    required this.status,
    required this.username,
  }): super.fromJson({});

  factory ResetPasswordSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordSuccessResponse(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      mobile: json['mobile'] ?? '',
      patientId: json['patient_id'] ?? '',
      status: json['status'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'mobile': mobile,
      'patient_id': patientId,
      'status': status,
      'username': username,
    };
  }
}
