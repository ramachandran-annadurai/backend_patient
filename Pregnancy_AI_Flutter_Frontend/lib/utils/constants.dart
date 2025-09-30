import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFBC77E4); // Blue
  static const Color secondary = Color(0xFFBC77E4); // Darker Blue
  static const Color background = Color(0xFFF8F9FA);
  static const Color border = Color(0xFFE1E5E9);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFFBC77E4);
  static const Color purple = Color(0xFFBC77E4);
  static const Color borderLight = Color(0xFFE1E5E9); // Light border
  static const Color cardBackground = Color(0xFFF8F9FA); // Card background
}

class ApiConfig {
  // Backend server URLs - configured for production deployment (from doctor folder)
  static const String baseUrl = 'https://pregnancy-ai.onrender.com';  // Main backend server
  static const String doctorBaseUrl = 'https://pregnancy-mobile-app.onrender.com';  // Doctor operations
  // IMPORTANT: Nutrition backend is now integrated into main backend
  static const String nutritionBaseUrl = 'https://pregnancy-ai.onrender.com';  // Now uses main backend
  
  // Alternative URLs for different platforms
  static const String baseUrlAlt = 'https://pregnancy-ai.onrender.com';
  static const String baseUrlLocal = 'https://pregnancy-ai.onrender.com';
  
  // Platform-specific URLs
  static const String androidEmulatorUrl = 'https://pregnancy-ai.onrender.com';  // Android emulator
  static const String iosSimulatorUrl = 'https://pregnancy-ai.onrender.com';     // iOS simulator
  
  // Get the best URL for the current platform
  static String getBestBaseUrl() {
    // For now, return the main URL
    // You can add platform detection logic here if needed
    return baseUrl;
  }
  
  // Get alternative URLs for testing
  static List<String> getAlternativeUrls() {
    return [
      baseUrl,
      baseUrlAlt,
      androidEmulatorUrl,
      iosSimulatorUrl,
    ];
  }
  
  // Voice transcription endpoint - MUST use nutritionBaseUrl (port 5000)
  static const String transcribeEndpoint = '/nutrition/transcribe';
  
  // Unified backend endpoints (as per API documentation from pregnancy-mobile-app.onrender.com)
  static const String signupEndpoint = '/auth/register';  // Register new patient
  static const String verifyOtpEndpoint = '/verify-otp';  // Verify OTP and activate account
  static const String loginEndpoint = '/login';  // Login with Patient ID/Email (for patients)
  static const String sendOtpEndpoint = '/send-otp';  // Send OTP to email
  static const String forgotPasswordEndpoint = '/forgot-password';  // Send password reset OTP
  static const String resetPasswordEndpoint = '/reset-password';  // Reset password with OTP
  static const String completeProfileEndpoint = '/complete-profile';  // Complete patient profile
  static const String getProfileEndpoint = '/profile';  // Get patient profile (with ID)
  
  // Patient-specific endpoints (legacy aliases for compatibility)
  static const String patientSignupEndpoint = '/signup';  // Same as signup
  static const String patientVerifyOtpEndpoint = '/verify-otp';  // Same as verify-otp
  static const String patientLoginEndpoint = '/login';  // Same as login
  static const String patientForgotPasswordEndpoint = '/forgot-password';  // Same as forgot-password
  static const String patientResetPasswordEndpoint = '/reset-password';  // Same as reset-password
  static const String patientCompleteProfileEndpoint = '/complete-profile';  // Same as complete-profile
  static const String patientProfileEndpoint = '/profile';  // Same as profile
  static const String patientSendOtpEndpoint = '/send-otp';  // Same as send-otp
  static const String patientResendOtpEndpoint = '/send-otp';  // Use send-otp for resend
  static const String completeNutritionEndpoint = '/complete-nutrition';
  static const String transcriptsEndpoint = '/transcripts';

  // Doctor-specific endpoints (use doctorBaseUrl for doctor operations)
  static const String doctorLoginEndpoint = '/doctor-login';
  static const String doctorSignupEndpoint = '/doctor-signup';  // Custom doctor signup endpoint
  static const String doctorSendOtpEndpoint = '/doctor-send-otp';  // Custom doctor send-otp endpoint
  static const String doctorVerifyOtpEndpoint = '/doctor-verify-otp';  // Custom doctor verify-otp endpoint
  static const String doctorResendOtpEndpoint = '/doctor-resend-otp';  // Custom doctor resend-otp endpoint
  static const String doctorForgotPasswordEndpoint = '/doctor-forgot-password';  // Custom doctor forgot-password endpoint
  static const String doctorResetPasswordEndpoint = '/doctor-reset-password';  // Custom doctor reset-password endpoint
  static const String doctorProfileEndpoint = '/doctor-profile';  // Custom doctor profile endpoint
  static const String doctorCompleteProfileEndpoint = '/doctor-complete-profile';  // Custom doctor complete-profile endpoint
  
  // Legacy endpoints for backward compatibility (redirect to doctor-specific)
  static const String completeDoctorProfileEndpoint = '/doctor-complete-profile';

}

class AppStrings {
  static const String appName = 'Patient Alert System';
  static const String loginTitle = 'Welcome Back';
  static const String signupTitle = 'Create Account';
  static const String forgotPasswordTitle = 'Reset Password';
  static const String profileTitle = 'Complete Profile';
  
  // Login
  static const String loginSubtitle = 'Sign in to your account';
  static const String patientIdOrEmail = 'Patient ID or Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String dontHaveAccount = "Don't have an account?";
  static const String signup = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';
  
  // Signup
  static const String signupSubtitle = 'Create your patient account';
  static const String username = 'Username';
  static const String email = 'Email';
  static const String mobile = 'Mobile Number';
  static const String confirmPassword = 'Confirm Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  
  // OTP
  static const String otpTitle = 'Verify OTP';
  static const String otpSubtitle = 'Enter the 6-digit code sent to your email';
  static const String otpCode = 'OTP Code';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  
  // Profile
  static const String profileSubtitle = 'Complete your profile information';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String dateOfBirth = 'Date of Birth';
  static const String bloodType = 'Blood Type';
  static const String isPregnant = 'Are you pregnant?';
  static const String lastPeriodDate = 'Last Period Date';
  static const String pregnancyWeek = 'Pregnancy Week';
  static const String expectedDelivery = 'Expected Delivery Date';
  static const String emergencyContact = 'Emergency Contact';
  static const String emergencyName = 'Emergency Contact Name';
  static const String emergencyRelationship = 'Relationship';
  static const String emergencyPhone = 'Emergency Contact Phone';
  static const String completeProfile = 'Complete Profile';
  
  // Messages
  static const String loading = 'Loading...';
  static const String success = 'Success!';
  static const String error = 'Error';
  static const String networkError = 'Network error. Please check your connection.';
  static const String invalidCredentials = 'Invalid credentials';
  static const String accountCreated = 'Account created successfully!';
  static const String profileCompleted = 'Profile completed successfully!';
  static const String otpSent = 'OTP sent to your email';
  static const String otpVerified = 'OTP verified successfully!';
  static const String passwordReset = 'Password reset successfully!';
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 48.0;
} 