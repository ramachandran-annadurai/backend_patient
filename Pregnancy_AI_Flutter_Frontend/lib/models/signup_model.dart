class SignupModel {
  final String username;
  final String email;
  final String mobile;
  final String password;
  final String firstName;
  final String lastName;
  final String userType;
  final bool isPregnant;

  const SignupModel({
    required this.username,
    required this.email,
    required this.mobile,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.isPregnant,
  });

  // Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'mobile': mobile,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'is_pregnant': isPregnant,
    };
  }

  // Create model from JSON response
  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      password: json['password'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userType: json['user_type'] ?? 'patient',
      isPregnant: json['is_pregnant'] ?? false,
    );
  }

}
