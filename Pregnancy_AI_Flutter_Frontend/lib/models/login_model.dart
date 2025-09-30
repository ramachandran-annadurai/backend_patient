import '../services/core/network_request.dart';

class LoginRequestModel{
  final String loginIdentifier;
  final String password;

  LoginRequestModel({
    required this.loginIdentifier,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "login_identifier": loginIdentifier,
      "password": password,
    };
  }
}

class LoginResponseModel extends NetworkResponse  {
  final String email;
  final bool isProfileComplete;
  final String message;
  final String objectId;
  final String patientId;
  final String sessionId;
  final String token;
  final String username;

  LoginResponseModel({
    required this.email,
    required this.isProfileComplete,
    required this.message,
    required this.objectId,
    required this.patientId,
    required this.sessionId,
    required this.token,
    required this.username,
  }): super.fromJson({});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      email: json['email'] ?? '',
      isProfileComplete: json['is_profile_complete'] ?? false,
      message: json['message'] ?? '',
      objectId: json['object_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      sessionId: json['session_id'] ?? '',
      token: json['token'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'is_profile_complete': isProfileComplete,
      'message': message,
      'object_id': objectId,
      'patient_id': patientId,
      'session_id': sessionId,
      'token': token,
      'username': username,
    };
  }

  @override
  String toString() {
    return 'LoginResponseModel(email: $email, isProfileComplete: $isProfileComplete, message: $message, objectId: $objectId, patientId: $patientId, sessionId: $sessionId, token: $token, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponseModel &&
        other.email == email &&
        other.isProfileComplete == isProfileComplete &&
        other.message == message &&
        other.objectId == objectId &&
        other.patientId == patientId &&
        other.sessionId == sessionId &&
        other.token == token &&
        other.username == username;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        isProfileComplete.hashCode ^
        message.hashCode ^
        objectId.hashCode ^
        patientId.hashCode ^
        sessionId.hashCode ^
        token.hashCode ^
        username.hashCode;
  }
}
