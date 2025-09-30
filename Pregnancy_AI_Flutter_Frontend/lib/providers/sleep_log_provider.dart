import 'package:flutter/foundation.dart';
import '../repositories/sleep_log_repository.dart';
import '../services/core/api_core.dart';
import '../models/sleep_log.dart';
import '../models/save_sleep_log_response.dart';

class SleepLogProvider extends ChangeNotifier {
  final SleepLogRepository _sleepLogRepository = SleepLogRepository();

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  SaveSleepLogResponseModel? _response;

  // Getters
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  SaveSleepLogResponseModel? get response => _response;

  // Save sleep log using repository
  Future<bool> saveSleepLog(SleepLogModel sleepLog) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    _response = null;
    notifyListeners();

    try {
      _response = await _sleepLogRepository.saveSleepLog(sleepLog);

      if (_response!.success) {
        _successMessage = _response!.message;
        return true;
      } else {
        _errorMessage = _response!.message;
        return false;
      }
    } on ErrorResponse catch (e) {
      _errorMessage = e.error;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _response = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    _response = null;
    notifyListeners();
  }
}
