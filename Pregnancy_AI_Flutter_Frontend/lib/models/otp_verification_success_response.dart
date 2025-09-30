import '../services/core/network_request.dart';
class OtpVerificationSuccessResponse extends NetworkResponse {
  final String email;
  final String message;
  final String mobile;
  final String patientId;
  final String status;
  final String token;
  final String username;

  OtpVerificationSuccessResponse({
    required this.email,
    required this.message,
    required this.mobile,
    required this.patientId,
    required this.status,
    required this.token,
    required this.username,
  }): super.fromJson({});

  factory OtpVerificationSuccessResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationSuccessResponse(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      mobile: json['mobile'] ?? '',
      patientId: json['patient_id'] ?? '',
      status: json['status'] ?? '',
      token: json['token'] ?? '',
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
      'token': token,
      'username': username,
    };
  }
}
