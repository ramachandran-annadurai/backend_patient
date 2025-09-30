import 'package:flutter/foundation.dart';
import '../repositories/nutrition_repository.dart';
import '../services/core/api_core.dart';
import '../models/food_entry.dart';

class SaveFoodEntryProvider extends ChangeNotifier {
  bool _isSaving = false;
  String? _errorMessage;
  bool _isSuccess = false;

  // Repository instance
  final NutritionRepository _nutritionRepository = NutritionRepository();

  // Getters
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  // Save food entry using repository (accepts Map or FoodEntryModel)
  Future<bool> saveFoodEntry(FoodEntryModel foodData) async {
    _isSaving = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final response = await _nutritionRepository.saveFoodEntryModel(foodData);

      if (response.success) {
        _isSuccess = true;
        return true;
      } else {
        _errorMessage = response.message;
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

  // Clear save state
  void clearSaveState() {
    _isSaving = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _isSaving = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
