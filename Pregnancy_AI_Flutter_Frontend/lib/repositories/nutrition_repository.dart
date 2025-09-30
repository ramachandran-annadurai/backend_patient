import '../services/patient_service/analyze_food_with_gpt4_service.dart';
import '../services/patient_service/get_gpt4_analysis_history_service.dart';
import '../services/patient_service/transcribe_audio_service.dart';
import '../services/patient_service/get_current_pregnancy_week_service.dart';
import '../services/patient_service/save_detailed_food_entry_service.dart';
import '../models/food_entry.dart';
import '../models/save_food_entry_response.dart';
import '../models/analyze_food_request.dart';
import '../models/analyze_food_response.dart';

class NutritionRepository {

  final AnalyzeFoodWithGPT4Service _analyzeFood = AnalyzeFoodWithGPT4Service();

  final GetGPT4AnalysisHistoryService _getHistory =
      GetGPT4AnalysisHistoryService();

  final TranscribeAudioService _transcribe = TranscribeAudioService();

  final GetCurrentPregnancyWeekService _getCurrentWeek =
      GetCurrentPregnancyWeekService();

  final SaveDetailedFoodEntryService _saveDetailedFoodEntry =
      SaveDetailedFoodEntryService();

  Future<AnalyzeFoodResponseModel> analyzeFood(
          AnalyzeFoodRequestModel request) =>
      _analyzeFood.call(request);

  Future<Map<String, dynamic>> getHistory(String userId) =>
      _getHistory.call(userId);

  Future<Map<String, dynamic>> transcribe(String audioBase64,
          {String language = 'auto'}) =>
      _transcribe.call(audioBase64, language: language);

  Future<Map<String, dynamic>> getCurrentPregnancyWeek(String userId) =>
      _getCurrentWeek.call(userId);

  Future<SaveFoodEntryResponseModel> saveDetailedFoodEntry(
          Map<String, dynamic> data) =>
      _saveDetailedFoodEntry.call(data);

  // Overload to accept FoodEntryModel without changing existing callers
  Future<SaveFoodEntryResponseModel> saveFoodEntryModel(FoodEntryModel entry) =>
      _saveDetailedFoodEntry.call(entry.toJson());
}
