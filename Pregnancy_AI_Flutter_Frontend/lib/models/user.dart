class UserModel {
  final String userId;
  final String email;
  final String username;
  final String? token;
  final String role;
  final String? objectId;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    required this.role,
    this.token,
    this.objectId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['userId'] ?? json['patient_id'] ?? json['doctor_id'] ?? json['_id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      token: json['token']?.toString(),
      objectId: (json['objectId'] ?? json['object_id'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'role': role,
      if (token != null) 'token': token,
      if (objectId != null) 'objectId': objectId,
    };
  }
}


