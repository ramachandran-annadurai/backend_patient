class ResetPasswordModel {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordModel({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "otp": otp,
      "new_password": newPassword,
    };
  }

  @override
  String toString() {
    return 'ResetPasswordModel(email: $email, otp: $otp, newPassword: [HIDDEN])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResetPasswordModel &&
        other.email == email &&
        other.otp == otp &&
        other.newPassword == newPassword;
  }

  @override
  int get hashCode {
    return email.hashCode ^ otp.hashCode ^ newPassword.hashCode;
  }
}
