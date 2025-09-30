import '../services/patient_service/login_service.dart';
import '../../models/login_model.dart';

class LoginRepository {
  final LoginService _loginService = LoginService();

  Future<LoginResponseModel> login(LoginRequestModel model) async {
    try {
      final response = await _loginService.call(
        loginIdentifier: model.loginIdentifier,
        password: model.password,
      );
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
