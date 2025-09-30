import '../services/core/network_request.dart';

class SignupSuccessResponse extends NetworkResponse {
  final String email;
  final String message;
  final String status;

  SignupSuccessResponse({
    required this.email,
    required this.message,
    required this.status,
  }): super.fromJson({});

  factory SignupSuccessResponse.fromJson(Map<String, dynamic> json) {
    return SignupSuccessResponse(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
      'status': status,
    };
  }
}
