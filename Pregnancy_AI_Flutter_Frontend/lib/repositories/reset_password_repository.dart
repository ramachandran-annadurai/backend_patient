import '../models/reset_password_model.dart';
import '../models/reset_password_success_response.dart';
import '../services/patient_service/reset_password_service.dart';

class ResetPasswordRepository {
  final ResetPasswordService _resetPasswordService = ResetPasswordService();

  Future<bool> resetPassword(ResetPasswordModel model) async {
    try {
      ResetPasswordSuccessResponse response = await _resetPasswordService.call(
        email: model.email,
        otp: model.otp,
        newPassword: model.newPassword,
      );

      // Check if the response indicates success
      if (response.message.contains('successfully')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
