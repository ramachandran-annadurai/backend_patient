import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/login_repository.dart';
import '../models/login_model.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  LoginResponseModel? _loginResponse;
  bool _isLoggedIn = false;

  final LoginRepository _loginRepository = LoginRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  LoginResponseModel? get loginResponse => _loginResponse;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> login(LoginRequestModel model) async {
    _isLoading = true;
    _error = null;
    _loginResponse = null;
    _isLoggedIn = false;
    notifyListeners();

    try {
      _loginResponse = await _loginRepository.login(model);
      _isLoggedIn = true;

      // Save user data to SharedPreferences after successful login
      if (_loginResponse != null) {
        await _saveUserToPrefs(_loginResponse!);
      }
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _loginResponse = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  /// Save user data to SharedPreferences after successful login
  Future<void> _saveUserToPrefs(LoginResponseModel response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('patientId', response.patientId);
      await prefs.setString('email', response.email);
      await prefs.setString('username', response.username);
      await prefs.setString('auth_token', response.token);
      await prefs.setString('role', 'patient'); // Default role for login flow
      await prefs.setString('objectId', response.objectId);

      // Set token in API core for subsequent requests
      // Note: Token will be set by AuthProvider when needed

      print('✅ User data saved to SharedPreferences:');
      print('  patientId: ${response.patientId}');
      print('  email: ${response.email}');
      print('  username: ${response.username}');
      print('  token: ${response.token}');
      print('  objectId: ${response.objectId}');
    } catch (e) {
      print('❌ Error saving user data to SharedPreferences: $e');
    }
  }
}
