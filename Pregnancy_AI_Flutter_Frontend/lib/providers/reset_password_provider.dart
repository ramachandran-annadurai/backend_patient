import 'package:flutter/foundation.dart';
import '../models/reset_password_model.dart';
import '../repositories/reset_password_repository.dart';

class ResetPasswordProvider extends ChangeNotifier {
  final ResetPasswordRepository _repository = ResetPasswordRepository();

  bool _isLoading = false;
  String? _error;
  bool _success = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get success => _success;

  Future<void> resetPassword(ResetPasswordModel model) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final result = await _repository.resetPassword(model);
      _success = result;
      _error = null;
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

  void reset() {
    _isLoading = false;
    _error = null;
    _success = false;
    notifyListeners();
  }
}
