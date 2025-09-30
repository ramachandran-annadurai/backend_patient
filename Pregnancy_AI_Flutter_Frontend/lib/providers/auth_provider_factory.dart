import 'package:flutter/material.dart';
import 'auth_provider.dart';
import 'patient_auth_provider.dart';
import 'doctor_auth_provider.dart';

class AuthProviderFactory extends ChangeNotifier {
  final AuthProvider _authProvider;
  late final PatientAuthProvider _patientAuthProvider;
  late final DoctorAuthProvider _doctorAuthProvider;

  AuthProviderFactory(this._authProvider) {
    _patientAuthProvider = PatientAuthProvider(_authProvider);
    _doctorAuthProvider = DoctorAuthProvider(_authProvider);

    // Listen to auth provider changes
    _authProvider.addListener(() {
      notifyListeners();
    });
  }

  // Expose the main auth provider
  AuthProvider get authProvider => _authProvider;

  // Expose patient-specific auth methods
  PatientAuthProvider get patient => _patientAuthProvider;

  // Expose doctor-specific auth methods
  DoctorAuthProvider get doctor => _doctorAuthProvider;

  // Common getters from main auth provider
  bool get isLoading => _authProvider.isLoading;
  bool get isLoggedIn => _authProvider.isLoggedIn;
  String? get token => _authProvider.token;
  String? get role => _authProvider.role;
  String? get email => _authProvider.email;
  String? get username => _authProvider.username;
  String? get userId =>
      _authProvider.patientId; // This works for both patient and doctor IDs
  String? get objectId => _authProvider.objectId;
  String? get error => _authProvider.error;

  // Common methods
  Future<void> checkLoginStatus() => _authProvider.checkLoginStatus();
  Future<void> logout() => _authProvider.logout();
  void clearError() => _authProvider.clearError();

  Future<Map<String, String?>> getCurrentUserInfo() =>
      _authProvider.getCurrentUserInfo();

  @override
  void dispose() {
    _authProvider.removeListener(() {
      notifyListeners();
    });
    super.dispose();
  }
}
