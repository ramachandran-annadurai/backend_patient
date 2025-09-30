import '../models/forgot_password_model.dart';
import '../models/forgot_password_success_response.dart';
import '../services/patient_service/forgot_password_service.dart';

class ForgotPasswordRepository {
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();

  Future<bool> forgotPassword(ForgotPasswordModel model) async {
    try {
      ForgotPasswordSuccessResponse response =
          await _forgotPasswordService.call(
        loginIdentifier: model.loginIdentifier,
      );

      // Check if response indicates success
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
