import 'package:flutter/foundation.dart';
import '../repositories/nutrition_repository.dart';
import '../services/core/api_core.dart';
import '../models/analyze_food_request.dart';
import '../models/analyze_food_response.dart';

class FoodAnalysisProvider extends ChangeNotifier {
  bool _isAnalyzing = false;
  AnalyzeFoodResponseModel? _analysisResult;
  String? _errorMessage;

  // Repository instance
  final NutritionRepository _nutritionRepository = NutritionRepository();

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  AnalyzeFoodResponseModel? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;

  // Analyze food with GPT-4 using repository
  Future<bool> analyzeFood(
      String foodDetails, int pregnancyWeek, String userId) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AnalyzeFoodRequestModel(
        foodInput: foodDetails,
        pregnancyWeek: pregnancyWeek,
        userId: userId,
      );

      final response = await _nutritionRepository.analyzeFood(request);

      _analysisResult = response;
      return true;
    } on ErrorResponse catch (e) {
      _errorMessage = e.error;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // Clear analysis results
  void clearAnalysis() {
    _analysisResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Reset all state
  void reset() {
    _isAnalyzing = false;
    _analysisResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
