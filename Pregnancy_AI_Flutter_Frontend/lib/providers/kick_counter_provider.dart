import 'package:flutter/material.dart';
import '../repositories/kick_repository.dart';
import '../models/kick_counter_request.dart';
import '../models/kick_counter_response.dart';

class KickCounterProvider extends ChangeNotifier {
  final KickRepository _repo;

  KickCounterProvider({KickRepository? repository})
      : _repo = repository ?? KickRepository();

  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _kickLogs = [];
  KickCounterResponseModel? _lastResponse;

  bool get isLoading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get kickLogs => _kickLogs;
  KickCounterResponseModel? get lastResponse => _lastResponse;

  Future<void> loadHistory(String userId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      final res = await _repo.getHistory(userId);
      if (res['success'] == true) {
        _kickLogs = List<Map<String, dynamic>>.from(res['kick_logs'] ?? []);
      } else if (res.containsKey('error')) {
        _error = res['error']?.toString();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSession(KickCounterRequestModel data) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();
      final res = await _repo.saveSession(data);
      _lastResponse = res;
      if (res.success) {
        // Optionally add to local list
        _kickLogs.add({
          'kickCount': data.kickCount,
          'sessionDuration': data.sessionDuration,
          'timestamp': DateTime.now().toIso8601String(),
        });
        return true;
      } else {
        _error = res.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
