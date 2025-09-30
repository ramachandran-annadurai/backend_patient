import 'package:flutter/material.dart';
import '../repositories/nutrition_repository.dart';

class DetailedFoodEntryProvider extends ChangeNotifier {
  final NutritionRepository _repo;

  DetailedFoodEntryProvider({NutritionRepository? repository})
      : _repo = repository ?? NutritionRepository();

  bool _loadingWeek = false;
  bool _saving = false;
  int? _pregnancyWeek;
  String? _error;

  bool get isLoadingWeek => _loadingWeek;
  bool get isSaving => _saving;
  int? get pregnancyWeek => _pregnancyWeek;
  String? get error => _error;

  Future<void> fetchPregnancyWeek(String userId) async {
    try {
      _loadingWeek = true;
      _error = null;
      notifyListeners();

      final res = await _repo.getCurrentPregnancyWeek(userId);
      if (res['success'] == true) {
        _pregnancyWeek = (res['current_pregnancy_week'] ?? 1) as int;
      } else if (res.containsKey('error')) {
        _error = res['error']?.toString();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingWeek = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> saveDetailedFoodEntry(
      Map<String, dynamic> data) async {
    try {
      _saving = true;
      _error = null;
      notifyListeners();

      final res = await _repo.saveDetailedFoodEntry(data);
      if (res.success != true && res.message.isNotEmpty) {
        _error = res.message.toString();
      }
      return res.toJson();
    } catch (e) {
      _error = e.toString();
      return {'error': _error};
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
