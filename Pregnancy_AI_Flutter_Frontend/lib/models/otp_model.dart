class OtpModel {
  final String email;
  final String otp;

  const OtpModel({
    required this.email,
    required this.otp,
  });

  // Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }

  // Create model from JSON response
  factory OtpModel.fromJson(Map<String, dynamic> json) {
    return OtpModel(
      email: json['email'] ?? '',
      otp: json['otp'] ?? '',
    );
  }

  @override
  String toString() {
    return 'OtpModel(email: $email, otp: $otp)';
  }
}
