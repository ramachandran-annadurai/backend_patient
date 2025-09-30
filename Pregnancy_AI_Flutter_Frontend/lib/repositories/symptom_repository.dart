import '../services/patient_service/symptom_analysis_service.dart';
import '../models/symptom_analysis_request.dart';
import '../models/symptom_analysis_response.dart';

class SymptomRepository {
  final SymptomAnalysisService _symptomAnalysis = SymptomAnalysisService();

  Future<SymptomAnalysisResponseModel> analyzeSymptom(
          SymptomAnalysisRequestModel request) =>
      _symptomAnalysis.call(request);
}
