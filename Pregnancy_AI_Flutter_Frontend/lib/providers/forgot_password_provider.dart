import 'package:flutter/foundation.dart';
import '../models/forgot_password_model.dart';
import '../repositories/forgot_password_repository.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final ForgotPasswordRepository _repository = ForgotPasswordRepository();

  bool _isLoading = false;
  String? _error;
  bool _success = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get success => _success;

  Future<void> sendResetRequest(String email) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final model = ForgotPasswordModel(loginIdentifier: email);
      final result = await _repository.forgotPassword(model);

      if (result) {
        _success = true;
        _error = null;
      } else {
        _error = 'Failed to send reset request';
        _success = false;
      }
    } catch (e) {
      _error = e.toString();
      _success = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _error = null;
    _success = false;
    notifyListeners();
  }
}
