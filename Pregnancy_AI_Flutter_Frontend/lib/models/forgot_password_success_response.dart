import '../services/core/network_request.dart';

class ForgotPasswordSuccessResponse extends NetworkResponse {
  final String email;
  final String message;

  ForgotPasswordSuccessResponse({
    required this.email,
    required this.message,
  }): super.fromJson({});

  factory ForgotPasswordSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordSuccessResponse(
      email: json['email'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'message': message,
    };
  }
}
