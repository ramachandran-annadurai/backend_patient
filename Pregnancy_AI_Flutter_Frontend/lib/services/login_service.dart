import 'package:shared_preferences/shared_preferences.dart';
import 'patient_service/api_login_service.dart';
import 'doctor_api_service.dart';

/// Standalone login service that handles authentication for both patients and doctors
class LoginService {
  final ApiLoginService _apiService = ApiLoginService();
  final DoctorApiService _doctorApiService = DoctorApiService();

  /// Login method that handles authentication for both patients and doctors
  ///
  /// Parameters:
  /// - [loginIdentifier]: Email or username for login
  /// - [password]: User password
  /// - [role]: Either 'patient' or 'doctor'
  ///
  /// Returns:
  /// - [LoginResult]: Contains success status, user data, and error information
  Future<LoginResult> login({
    required String loginIdentifier,
    required String password,
    required String role,
  }) async {
    try {
      Map<String, dynamic> response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        response = await _doctorApiService.login(
          loginIdentifier: loginIdentifier,
          password: password,
          role: role,
        );
      } else {
        response = await _apiService.call(
          loginIdentifier: loginIdentifier,
          password: password,
          role: role,
        );
      }

      if (response.containsKey('error')) {
        return LoginResult(
          success: false,
          error: response['error'],
        );
      }

      // Handle both patient and doctor login responses more flexibly
      bool hasValidResponse = false;
      String? patientId;
      String? email;
      String? username;
      String? token;
      String? objectId;

      if (role == 'doctor') {
        // Doctor login response - more flexible approach like doctor folder
        if (response['doctor_id'] != null || response['email'] != null) {
          hasValidResponse = true;
          patientId = response['doctor_id'] ??
              response['user_id'] ??
              response['id'] ??
              response['doctorId'] ??
              response['userId'] ??
              response['_id'] ??
              "";
          email = response['email'] ?? "";
          username = response['name'] ??
              response['username'] ??
              ""; // Doctors might have 'name' field
          token = response['token'] ?? "";
          objectId = response['object_id'] ?? response['objectId'] ?? "";
        }
      } else {
        // Patient login response
        String? userId = response['patient_id'] ??
            response['user_id'] ??
            response['id'] ??
            response['patientId'] ??
            response['userId'] ??
            response['_id'];

        if (userId != null && userId.isNotEmpty) {
          hasValidResponse = true;
          patientId = userId;
          email = response['email'] ?? "";
          username = response['username'] ?? "";
          token = response['token'] ?? "";
          objectId = response['object_id'] ?? response['objectId'] ?? "";
        }
      }

      if (hasValidResponse) {
        // Debug logging to see what we received
        print('🔍 LoginService Debug - Login Response ($role):');
        print('  user_id: $patientId');
        print('  email: $email');
        print('  username: $username');
        print('  token: $token');
        print('  object_id: $objectId');

        // More flexible validation - only require email and at least one of username/token
        if ((email?.isEmpty ?? true) ||
            ((username?.isEmpty ?? true) && (token?.isEmpty ?? true))) {
          return LoginResult(
            success: false,
            error:
                'Login response missing required fields (email: ${email?.isEmpty}, username: ${username?.isEmpty}, token: ${token?.isEmpty})',
          );
        }

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('patientId',
            patientId ?? ""); // Store as patientId for compatibility
        await prefs.setString('email', email ?? "");
        await prefs.setString('username', username ?? "");
        await prefs.setString('auth_token', token ?? "");
        await prefs.setString('role', role);
        await prefs.setString(
            'objectId', objectId ?? ""); // Save Object ID (can be empty string)

        // Debug logging for SharedPreferences
        print('🔍 LoginService Debug - SharedPreferences Saved:');
        print('  isLoggedIn: true');
        print('  patientId: $patientId');
        print('  email: $email');
        print('  username: $username');
        print('  token: $token');
        print('  role: $role');
        print('  objectId: $objectId');

        // Set token in appropriate API service
        if (role == 'doctor') {
          DoctorApiService.setAuthToken(token ?? "");
        }

        return LoginResult(
          success: true,
          userData: UserData(
            userId: patientId ?? "",
            email: email ?? "",
            username: username ?? "",
            token: token ?? "",
            role: role,
            objectId: objectId ?? "",
          ),
        );
      } else {
        return LoginResult(
          success: false,
          error: 'Login failed - missing user identification',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        error: 'Network error: $e',
      );
    }
  }
}

/// Result class for login operations
class LoginResult {
  final bool success;
  final UserData? userData;
  final String? error;

  LoginResult({
    required this.success,
    this.userData,
    this.error,
  });
}

/// User data class to hold login information
class UserData {
  final String userId;
  final String email;
  final String username;
  final String token;
  final String role;
  final String objectId;

  UserData({
    required this.userId,
    required this.email,
    required this.username,
    required this.token,
    required this.role,
    required this.objectId,
  });

  /// Convert to Map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'token': token,
      'role': role,
      'objectId': objectId,
    };
  }

  /// Create from Map for deserialization
  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      token: map['token'] ?? '',
      role: map['role'] ?? '',
      objectId: map['objectId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserData(userId: $userId, email: $email, username: $username, role: $role, objectId: $objectId)';
  }
}
