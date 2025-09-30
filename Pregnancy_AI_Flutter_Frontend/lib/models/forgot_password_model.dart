class ForgotPasswordModel {
  final String loginIdentifier;

  const ForgotPasswordModel({
    required this.loginIdentifier,
  });

  Map<String, dynamic> toJson() {
    return {
      "login_identifier": loginIdentifier,
    };
  }

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      loginIdentifier: json['login_identifier'] as String,
    );
  }

  @override
  String toString() {
    return 'ForgotPasswordModel(loginIdentifier: $loginIdentifier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ForgotPasswordModel &&
        other.loginIdentifier == loginIdentifier;
  }

  @override
  int get hashCode {
    return loginIdentifier.hashCode;
  }
}
