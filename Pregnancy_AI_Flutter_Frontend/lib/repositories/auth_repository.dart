import '../services/patient_service/api_login_service.dart';
import '../services/patient_service/signup_service.dart';
import '../services/patient_service/verify_otp_service.dart';
import '../services/patient_service/resend_otp_service.dart';
import '../services/patient_service/forgot_password_service.dart';
import '../services/patient_service/reset_password_service.dart';
import '../services/patient_service/verify_token_service.dart';
import '../models/user.dart';
import '../models/signup_model.dart';
import '../models/otp_model.dart';
import '../models/signup_success_response.dart';
import '../models/otp_verification_success_response.dart';
import '../models/forgot_password_success_response.dart';
import '../models/reset_password_success_response.dart';
import '../services/core/api_core.dart';

class AuthRepository {
  final ApiLoginService _login;
  final SignupService _signup;
  final VerifyOtpService _verifyOtp;
  final ResendOtpService _resendOtp;
  final ForgotPasswordService _forgotPassword;
  final ResetPasswordService _resetPassword;
  final VerifyTokenService _verifyToken;

  AuthRepository({
    ApiLoginService? login,
    SignupService? signup,
    VerifyOtpService? verifyOtp,
    ResendOtpService? resendOtp,
    ForgotPasswordService? forgotPassword,
    ResetPasswordService? resetPassword,
    VerifyTokenService? verifyToken,
  })  : _login = login ?? ApiLoginService(),
        _signup = signup ?? SignupService(),
        _verifyOtp = verifyOtp ?? VerifyOtpService(),
        _resendOtp = resendOtp ?? ResendOtpService(),
        _forgotPassword = forgotPassword ?? ForgotPasswordService(),
        _resetPassword = resetPassword ?? ResetPasswordService(),
        _verifyToken = verifyToken ?? VerifyTokenService();

  // Existing raw map method (kept for current providers)
  Future<Map<String, dynamic>> login(
      {required String id, required String password, required String role}) {
    return _login.call(loginIdentifier: id, password: password, role: role);
  }

  // New typed alternative for future migration
  Future<UserModel> loginAsModel(
      {required String id,
      required String password,
      required String role}) async {
    final res =
        await _login.call(loginIdentifier: id, password: password, role: role);
    if (res.containsKey('error')) {
      throw Exception(res['error'].toString());
    }
    return UserModel.fromJson(res);
  }

  Future<SignupSuccessResponse> signup(SignupModel signupModel) async {
    try {
      return await _signup.call(
        username: signupModel.username,
        firstName: signupModel.firstName,
        lastName: signupModel.lastName,
        email: signupModel.email,
        mobile: signupModel.mobile,
        password: signupModel.password,
        role: signupModel.userType,
        isPregnant: signupModel.isPregnant,
      );
    } on ErrorResponse catch (e) {
      // Repository-level error handling for signup conflicts
      if (e.error == 'USER_EXISTS') {
        print('📊 Repository: User registration conflict detected');
      }

      // Re-throw ErrorResponse for provider to handle UI logic
      rethrow;
    }
  }

  Future<OtpVerificationSuccessResponse> verifyOtp(OtpModel otpModel,
      {required String role}) async {
    try {
      return await _verifyOtp.call(otpModel, role: role);
    } on ErrorResponse catch (e) {
      // Repository-level error handling for OTP verification
      if (e.error == 'INVALID_OTP' || e.error == 'OTP_EXPIRED') {
        print('📊 Repository: OTP verification failed - ${e.error}');
      }

      // Re-throw ErrorResponse for provider to handle UI logic
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp(
      {required String email, required String role}) {
    return _resendOtp.call(email: email, role: role);
  }

  Future<ForgotPasswordSuccessResponse> forgotPassword(
      {required String loginIdentifier}) {
    return _forgotPassword.call(loginIdentifier: loginIdentifier);
  }

  Future<ResetPasswordSuccessResponse> resetPassword(
      {required String email,
      required String otp,
      required String newPassword}) {
    return _resetPassword.call(
        email: email, otp: otp, newPassword: newPassword);
  }

  Future<Map<String, dynamic>> verifyToken({required String token}) {
    return _verifyToken.call(token: token);
  }
}
