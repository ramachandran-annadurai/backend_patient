import 'package:flutter/foundation.dart';
import '../repositories/symptom_repository.dart';
import '../services/core/api_core.dart';
import '../models/symptom_analysis_request.dart';
import '../models/symptom_analysis_response.dart';

class SymptomAnalysisProvider extends ChangeNotifier {
  bool _isAnalyzing = false;
  SymptomAnalysisResponseModel? _analysisResult;
  String? _errorMessage;

  // Repository instance
  final SymptomRepository _symptomRepository = SymptomRepository();

  // Getters
  bool get isAnalyzing => _isAnalyzing;
  SymptomAnalysisResponseModel? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;

  // Analyze symptom using repository
  Future<bool> analyzeSymptom(
      String text,
      String patientId,
      int weeksPregnant,
      String severity,
      String? notes,
      String? transcribedText,
      String date,
      String userRole,
      Map<String, dynamic> patientContext) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = SymptomAnalysisRequestModel(
        text: text,
        patientId: patientId,
        weeksPregnant: weeksPregnant,
        severity: severity,
        notes: notes,
        transcribedText: transcribedText,
        date: date,
        userRole: userRole,
        patientContext: PatientContext.fromJson(patientContext),
      );

      final response = await _symptomRepository.analyzeSymptom(request);

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
