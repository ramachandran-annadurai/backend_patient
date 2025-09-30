import 'package:patient_alert_app/models/forgot_password_success_response.dart';
import 'package:patient_alert_app/models/otp_verification_success_response.dart';
import 'package:patient_alert_app/models/reset_password_success_response.dart';
import '../services/patient_service/api_login_service.dart';
import '../services/patient_service/resend_otp_service.dart';
import '../services/patient_service/forgot_password_service.dart';
import '../services/patient_service/reset_password_service.dart';
import '../repositories/auth_repository.dart';
import '../models/signup_model.dart';
import '../models/otp_model.dart';
import '../services/core/api_core.dart';
import 'auth_provider.dart';

class PatientAuthProvider {
  final ApiLoginService _loginService = ApiLoginService();
  final ResendOtpService _resendOtpService = ResendOtpService();
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();
  final ResetPasswordService _resetPasswordService = ResetPasswordService();
  final AuthRepository _authRepository = AuthRepository();
  final AuthProvider _authProvider;

  PatientAuthProvider(this._authProvider);

  Future<bool> login(String identifier, String password) async {
    _authProvider.setLoading(true);

    try {
      final response = await _loginService.call(
        loginIdentifier: identifier,
        password: password,
        role: 'patient',
      );

      if (response.containsKey('error')) {
        _authProvider.setError(response['error']);
        _authProvider.setLoading(false);
        return false;
      }

      final userId = response['patient_id'] ??
          response['user_id'] ??
          response['_id'] ??
          "";
      final responseEmail = response['email'] ?? "";
      final username = response['username'] ?? "";
      final token = response['token'] ?? "";

      if (userId.isEmpty || responseEmail.isEmpty || token.isEmpty) {
        _authProvider.setError("Invalid response from server");
        _authProvider.setLoading(false);
        return false;
      }

      await _authProvider.saveUserToPrefs(
        userId: userId,
        email: responseEmail,
        username: username,
        token: token,
        role: 'patient',
        objectId: response['objectId'],
      );

      _authProvider.setLoading(false);
      return true;
    } catch (e) {
      _authProvider.setError("Login failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
  }

  Future<bool> signup(SignupModel signupModel) async {
    print('🔍 Signup Model: $signupModel');
    _authProvider.setLoading(true);

    try {
      final response = await _authRepository.signup(signupModel);

      if (!response.status.contains('otp_sent')) {
        final error = response.message;
        String errorMessage = _extractCleanErrorMessage(error);

        _authProvider.setError(errorMessage);
        _authProvider.setLoading(false);
        return false;
      }

      _authProvider.setLoading(false);
      return true;
    } on ErrorResponse catch (e) {
      // Handle specific 409 Resource Conflict errors at provider level
      if (e.error == 'USER_EXISTS') {
        _authProvider.setError('User already exists. ${e.error}');
      } else {
        _authProvider.setError(e.error);
      }
      _authProvider.setLoading(false);
      return false;
    } catch (e) {
      _authProvider.setError("Signup failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
  }

  Future<bool> verifyOtp(OtpModel otpModel) async {
    _authProvider.setLoading(true);

    try {
      OtpVerificationSuccessResponse response =
          await _authRepository.verifyOtp(otpModel, role: 'patient');

      if (!response.status.contains('active')) {
        _authProvider.setError(response.message);
        _authProvider.setLoading(false);
        return false;
      }

      // Save user data to preferences
      await _authProvider.saveUserToPrefs(
        userId: response.patientId,
        email: response.email,
        username: response.username,
        token: response.token,
        role: 'patient',
        objectId: response.patientId,
      );

      _authProvider.setLoading(false);
      return true;
    } on ErrorResponse catch (e) {
      // Handle specific OTP verification errors
      if (e.error== 'INVALID_OTP') {
        _authProvider.setError('Invalid OTP code. Please try again.');
      } else if (e.error == 'OTP_EXPIRED') {
        _authProvider.setError('OTP has expired. Please request a new one.');
      } else {
        _authProvider.setError(e.error);
      }
      _authProvider.setLoading(false);
      return false;
    } catch (e) {
      _authProvider.setError("OTP verification failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
  }

  Future<bool> resendOtp({
    required String email,
  }) async {
    _authProvider.setLoading(true);

    try {
      final response = await _resendOtpService.call(
        email: email,
        role: 'patient',
      );

      if (response.containsKey('error')) {
        _authProvider.setError(response['error']);
        _authProvider.setLoading(false);
        return false;
      }

      _authProvider.setLoading(false);
      return true;
    } catch (e) {
      _authProvider.setError("Resend OTP failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
  }

  Future<bool> forgotPassword({
    required String loginIdentifier,
  }) async {
    _authProvider.setLoading(true);

    try {
      ForgotPasswordSuccessResponse response =
          await _forgotPasswordService.call(loginIdentifier: loginIdentifier);

      if (!response.message.contains('successfully')) {
        _authProvider.setError(response.message);
        _authProvider.setLoading(false);
        return false;
      }

      _authProvider.setLoading(false);
      return true;
    } catch (e) {
      _authProvider.setError("Forgot password failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _authProvider.setLoading(true);

    try {
      ResetPasswordSuccessResponse response = await _resetPasswordService.call(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (!response.status.contains('active')) {
        _authProvider.setError(response.message);
        _authProvider.setLoading(false);
        return false;
      }

      _authProvider.setLoading(false);
      return true;
    } catch (e) {
      _authProvider.setError("Reset password failed: $e");
      _authProvider.setLoading(false);
      return false;
    }
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
