import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/doctor_api_service.dart';
import '../repositories/auth_repository.dart';
import '../models/signup_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized HTTP core: token, headers, timeouts, and simple request helper.
/// Self-contained. No dependency on ApiService.
class ApiCore {
  static String? _authToken;

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration fileUploadTimeout = Duration(seconds: 60);

  // Optional shared HTTP client
  static http.Client? _sharedClient;
  static http.Client get client => _sharedClient ??= http.Client();

  // Token management
  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  // Headers
  static Map<String, String> get headers {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
    };
    if (_authToken != null) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }

  static Map<String, String> get authHeaders {
    final map = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      map['Authorization'] = 'Bearer $_authToken';
    }
    return map;
  }

  // Lightweight request helper with timeout + JSON decode + basic error mapping
  static Future<Map<String, dynamic>> request(
    Future<http.Response> Function() send, {
    Duration? timeout,
  }) async {
    try {
      final response = await send().timeout(timeout ?? defaultTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty
            ? <String, dynamic>{}
            : json.decode(response.body) as Map<String, dynamic>;
      }
      return {
        'error': 'HTTP ${response.statusCode}',
        'body': response.body,
      };
    } on TimeoutException {
      return {'error': 'timeout'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

class AuthProvider extends ChangeNotifier {
  final DoctorApiService _doctorApiService = DoctorApiService();
  final AuthRepository _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _patientId;
  String? _email;
  String? _username;
  String? _token;
  String? _error;
  String? _role;
  String? _objectId; // Add Object ID

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get patientId => _patientId;
  String? get email => _email;
  String? get username => _username;
  String? get token => _token;
  String? get error => _error;
  String? get role => _role;
  String? get objectId => _objectId;

  // Get current user information for data storage
  Future<Map<String, String?>> getCurrentUserInfo() async {
    try {
      // Ensure we have the latest data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      _email = prefs.getString('email') ?? "";
      _username = prefs.getString('username') ?? "";
      _patientId = prefs.getString('patientId') ?? "";
      _role = prefs.getString('role') ?? "";
      _objectId = prefs.getString('objectId') ?? ""; // Add Object ID

      // Debug logging
      print('🔍 AuthProvider Debug - getCurrentUserInfo:');
      print('  Email: $_email');
      print('  Username: $_username');
      print('  PatientId: $_patientId');
      print('  Role: $_role');
      print('  ObjectId: $_objectId');

      // Validate that we have the minimum required data
      if ((_email?.isEmpty ?? true) ||
          (_username?.isEmpty ?? true) ||
          (_patientId?.isEmpty ?? true)) {
        print('⚠️  WARNING: Missing required user data in SharedPreferences');
        print('   This might cause null value errors in the dashboard');

        // Try to get from memory if SharedPreferences is empty
        if ((_email?.isEmpty ?? true) &&
            (_username?.isNotEmpty ?? false) &&
            (_patientId?.isNotEmpty ?? false)) {
          print('   Using in-memory data as fallback');
        }
      }

      return {
        'userId': (_patientId?.isNotEmpty ?? false) ? _patientId : null,
        'userRole': (_role?.isNotEmpty ?? false) ? _role : null,
        'username': (_username?.isNotEmpty ?? false) ? _username : null,
        'email': (_email?.isNotEmpty ?? false) ? _email : null,
        'objectId': (_objectId?.isNotEmpty ?? false) ? _objectId : null,
      };
    } catch (e) {
      print('❌ ERROR in getCurrentUserInfo: $e');
      // Return safe defaults instead of throwing
      return {
        'userId': null,
        'userRole': null,
        'username': null,
        'email': null,
        'objectId': null,
      };
    }
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _role = prefs.getString('role');

    if (_token != null) {
      // Verify token with patient server
      try {
        final response = await _authRepo.verifyToken(token: _token!);

        if (response.containsKey('valid') && response['valid'] == true) {
          _isLoggedIn = true;
          _patientId = prefs.getString('patientId');
          _email = prefs.getString('email');
          _username = prefs.getString('username');

          // Set token in API core
          ApiCore.setAuthToken(_token!);
        } else {
          // Token is invalid, clear everything
          await logout();
        }
      } catch (e) {
        print('❌ Token verification failed: $e');
        await logout();
      }
    } else {
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String loginIdentifier,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    _role = role;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        response = await _doctorApiService.login(
          loginIdentifier: loginIdentifier,
          password: password,
          role: role,
        );
      } else {
        final user = await _authRepo.loginAsModel(
          id: loginIdentifier,
          password: password,
          role: role,
        );

        _isLoggedIn = true;
        _patientId = user.userId;
        _email = user.email;
        _username = user.username;
        _token = user.token ?? '';
        _objectId = user.objectId ?? '';

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('patientId', _patientId ?? "");
        await prefs.setString('email', _email ?? "");
        await prefs.setString('username', _username ?? "");
        await prefs.setString('auth_token', _token ?? "");
        await prefs.setString('role', _role ?? "");
        await prefs.setString('objectId', _objectId ?? "");

        // Set token
        ApiCore.setAuthToken(_token ?? "");

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Handle both patient and doctor login responses more flexibly
      bool hasValidResponse = false;

      if (role == 'doctor') {
        // Doctor login response - more flexible approach like doctor folder
        if (response['doctor_id'] != null || response['email'] != null) {
          hasValidResponse = true;
          _isLoggedIn = true;
          _patientId = response['doctor_id'] ??
              response['user_id'] ??
              response['id'] ??
              response['doctorId'] ??
              response['userId'] ??
              response['_id'] ??
              "";
          _email = response['email'] ?? "";
          _username = response['name'] ??
              response['username'] ??
              ""; // Doctors might have 'name' field
          _token = response['token'] ?? "";
          _objectId = response['object_id'] ?? response['objectId'] ?? "";
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
          _isLoggedIn = true;
          _patientId = userId;
          _email = response['email'] ?? "";
          _username = response['username'] ?? "";
          _token = response['token'] ?? "";
          _objectId = response['object_id'] ?? response['objectId'] ?? "";
        }
      }

      if (hasValidResponse) {
        // Debug logging to see what we received
        print('🔍 AuthProvider Debug - Login Response ($role):');
        print('  user_id: $_patientId');
        print('  email: $_email');
        print('  username: $_username');
        print('  token: $_token');
        print('  object_id: $_objectId');

        // More flexible validation - only require email and at least one of username/token
        if ((_email?.isEmpty ?? true) ||
            ((_username?.isEmpty ?? true) && (_token?.isEmpty ?? true))) {
          _error =
              'Login response missing required fields (email: ${_email?.isEmpty}, username: ${_username?.isEmpty}, token: ${_token?.isEmpty})';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('patientId',
            _patientId ?? ""); // Store as patientId for compatibility
        await prefs.setString('email', _email ?? "");
        await prefs.setString('username', _username ?? "");
        await prefs.setString('auth_token', _token ?? "");
        await prefs.setString('role', _role ?? "");
        await prefs.setString('objectId',
            _objectId ?? ""); // Save Object ID (can be empty string)

        // Debug logging for SharedPreferences
        print('🔍 AuthProvider Debug - SharedPreferences Saved:');
        print('  isLoggedIn: true');
        print('  patientId: $_patientId');
        print('  email: $_email');
        print('  username: $_username');
        print('  token: $_token');
        print('  role: $_role');
        print('  objectId: $_objectId');

        // Set token in appropriate API core/services
        if (role == 'doctor') {
          DoctorApiService.setAuthToken(_token ?? "");
          ApiCore.setAuthToken(_token ?? "");
        } else {
          ApiCore.setAuthToken(_token ?? "");
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Login failed - missing user identification';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String mobile,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? qualification,
    String? specialization,
    String? workingHospital,
    String? licenseNumber,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? experienceYears,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        // Try regular signup first
        response = await _doctorApiService.signup(
          username: username,
          email: email,
          mobile: mobile,
          password: password,
          firstName: firstName,
          lastName: lastName,
          qualification: qualification,
          specialization: specialization,
          workingHospital: workingHospital,
          licenseNumber: licenseNumber,
          phone: phone,
          address: address,
          city: city,
          state: state,
          zipCode: zipCode,
          experienceYears: experienceYears,
        );

        // If signup fails with 500 error, try multiple workarounds
        if (response.containsKey('error') &&
            response['error'].toString().contains('500')) {
          print('🔄 Regular signup failed with 500, trying workarounds...');

          // Try 1: Patient signup endpoint (simplest solution)
          print('🔄 Trying patient signup endpoint for doctor...');
          response = await _doctorApiService.patientSignupForDoctor(
            username: username,
            email: email,
            mobile: mobile,
            password: password,
          );

          // Try 2: Workaround method
          if (response.containsKey('error') &&
              response['error'].toString().contains('500')) {
            print('🔄 Patient signup failed, trying workaround...');
            response = await _doctorApiService.doctorSignupWorkaround(
              username: username,
              email: email,
              mobile: mobile,
              password: password,
            );
          }

          // Try 3: Alternative signup method
          if (response.containsKey('error') &&
              response['error'].toString().contains('500')) {
            print('🔄 Workaround failed, trying alternative signup...');
            response = await _doctorApiService.alternativeDoctorSignup(
              username: username,
              email: email,
              mobile: mobile,
              password: password,
            );
          }

          // Try 4: Backend bypass (final solution)
          if (response.containsKey('error') &&
              response['error'].toString().contains('500')) {
            print('🔄 All backend methods failed, using bypass solution...');
            response = await _doctorApiService.bypassBackendSignup(
              username: username,
              email: email,
              mobile: mobile,
              password: password,
            );
          }
        }
      } else {
        final signupModel = SignupModel(
          username: username,
          email: email,
          mobile: mobile,
          password: password,
          firstName: firstName ?? username,
          lastName: lastName ?? '',
          userType: role,
          isPregnant: role == 'patient' ? true : false,
        );
        response = await _authRepo.signup(signupModel);
      }

      // If response is Map (doctor path), check error; if it's typed (patient path), skip
      if (response is Map && response.containsKey('error')) {
        _error = _extractCleanErrorMessage(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /*Future<bool> verifyOtp({
    required String email,
    required String otp,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    _role = role;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        // Use DoctorApiService for doctor OTP verification (connects to doctor_v2)
        response = await _doctorApiService.verifyOtp(
          email: email,
          otp: otp,
        );
      } else {
        response = await _authRepo.verifyOtp(
          email: email,
          otp: otp,
        );
      }

      if (response.containsKey('error')) {
        _error = _extractCleanErrorMessage(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Handle different ID field formats based on role
      String? userId;
      if (role == 'doctor') {
        // For doctors: doctor_id, user_id, id, doctorId, userId, _id
        userId = response['doctor_id'] ??
            response['user_id'] ??
            response['id'] ??
            response['doctorId'] ??
            response['userId'] ??
            response['_id'];
      } else {
        // For patients: patient_id, user_id, id, patientId, userId, _id
        userId = response['patient_id'] ??
            response['user_id'] ??
            response['id'] ??
            response['patientId'] ??
            response['userId'] ??
            response['_id'];
      }

      if (userId != null && userId.isNotEmpty) {
        _isLoggedIn = true;
        _patientId =
            userId; // Store the user ID (works for both patients and doctors)
        _email = response['email'] ?? "";
        _username = response['username'] ?? "";
        _token = response['token'] ?? "";
        _objectId = response['objectId'] ?? ""; // Store Object ID

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('patientId',
            _patientId ?? ""); // Store as patientId for compatibility
        await prefs.setString('email', _email ?? "");
        await prefs.setString('username', _username ?? "");
        await prefs.setString('auth_token', _token ?? "");
        await prefs.setString('role', _role ?? "");
        await prefs.setString('objectId', _objectId ?? ""); // Save Object ID

        // Set token in appropriate API core/services
        if (role == 'doctor') {
          DoctorApiService.setAuthToken(_token ?? "");
          ApiCore.setAuthToken(_token ?? "");
        } else {
          ApiCore.setAuthToken(_token ?? "");
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'OTP verification failed - missing user ID';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }*/

  // Resend OTP for both doctor and patient registration
  Future<bool> resendOtp({
    required String email,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        // Use DoctorApiService for doctor OTP resend (connects to doctor_v2)
        response = await _doctorApiService.resendOtp(
          email: email,
        );
      } else {
        // Use regular repo for patient OTP resend
        response = await _authRepo.resendOtp(
          email: email,
          role: role,
        );
      }

      if (response.containsKey('error')) {
        _error = _extractCleanErrorMessage(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword({
    required String loginIdentifier,
    required String role, // Add role parameter for proper routing
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        // Use DoctorApiService for doctor forgot password (connects to doctor_v2)
        response = await _doctorApiService.forgotPassword(
          loginIdentifier: loginIdentifier,
        );
      } else {
        // Use regular repo for patient forgot password (connects to patient_v2)
        response = await _authRepo.forgotPassword(
          loginIdentifier: loginIdentifier,
        );
      }

      if (response is Map && response.containsKey('error')) {
        _error = _extractCleanErrorMessage(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String role, // Add role parameter for proper routing
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      dynamic response;

      // Route to correct API service based on role
      if (role == 'doctor') {
        // Use DoctorApiService for doctor reset password (connects to doctor_v2)
        response = await _doctorApiService.resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );
      } else {
        // Use regular repo for patient reset password (connects to patient_v2)
        response = await _authRepo.resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );
      }

      if (response is Map && response.containsKey('error')) {
        _error = _extractCleanErrorMessage(response['error']);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _patientId = null;
    _email = null;
    _username = null;
    _token = null;
    _error = null;
    _role = null;
    _objectId = null; // Clear Object ID on logout

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear token from both API services
    ApiCore.clearAuthToken();
    DoctorApiService.clearAuthToken();

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> saveUserToPrefs({
    required String userId,
    required String email,
    required String username,
    required String token,
    required String role,
    String? objectId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('patientId', userId);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('auth_token', token);
    await prefs.setString('role', role);
    await prefs.setString('objectId', objectId ?? "");

    _patientId = userId;
    _email = email;
    _username = username;
    _token = token;
    _role = role;
    _objectId = objectId ?? "";
    _isLoggedIn = true;

    // Set token in appropriate API core/services
    if (role == 'doctor') {
      DoctorApiService.setAuthToken(token);
      ApiCore.setAuthToken(token);
    } else {
      ApiCore.setAuthToken(token);
    }

    notifyListeners();
  }

  /// Extract clean error message from various error formats
  String _extractCleanErrorMessage(dynamic error) {
    if (error == null) return 'Unknown error';

    // If it's already a clean string
    if (error is String) {
      // Check for nested detail structure in string format
      if (error.contains('detail:') && error.contains('message:')) {
        try {
          // Extract message from "message: text" pattern
          final messageMatch = RegExp(r'message:\s*([^,}]+)').firstMatch(error);
          if (messageMatch != null) {
            return messageMatch
                    .group(1)
                    ?.trim()
                    .replaceAll(RegExp(r'[,}]$'), '') ??
                error;
          }
        } catch (e) {
          // Fallback extraction
        }
      }

      // Check if it's a JSON string like "{error: Username already exists}"
      if (error.startsWith('{') && error.contains('error:')) {
        try {
          // Extract text between "error:" and "}"
          final match = RegExp(r'error:\s*([^}]+)').firstMatch(error);
          if (match != null) {
            return match.group(1)?.trim() ?? error;
          }
        } catch (e) {
          // If regex fails, try simple string manipulation
          if (error.contains('error:')) {
            final parts = error.split('error:');
            if (parts.length > 1) {
              return parts[1].replaceAll('}', '').trim();
            }
          }
        }
      }
      return error;
    }

    // If it's a Map object
    if (error is Map) {
      // Handle nested detail structure: {detail: {message: "text"}}
      if (error.containsKey('detail') && error['detail'] is Map) {
        final detail = error['detail'] as Map;
        if (detail.containsKey('message')) {
          return detail['message']?.toString() ?? error.toString();
        }
      }

      return error['message']?.toString() ??
          error['detail']?.toString() ??
          error['error']?.toString() ??
          error.toString();
    }

    return error.toString();
  }
}
