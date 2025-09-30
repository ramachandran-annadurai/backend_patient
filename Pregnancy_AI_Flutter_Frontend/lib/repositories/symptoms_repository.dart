import '../services/patient_service/analyze_symptoms_service.dart';
import '../services/patient_service/save_symptom_analysis_report_service.dart';
import '../services/patient_service/get_symptom_analysis_reports_service.dart';

class SymptomsRepository {
  final AnalyzeSymptomsService _analyze = AnalyzeSymptomsService();
  final SaveSymptomAnalysisReportService _saveReport = SaveSymptomAnalysisReportService();
  final GetSymptomAnalysisReportsService _getReports = GetSymptomAnalysisReportsService();

  Future<Map<String, dynamic>> analyze(Map<String, dynamic> data) => _analyze.call(data);
  Future<Map<String, dynamic>> saveReport(Map<String, dynamic> data) => _saveReport.call(data);
  Future<Map<String, dynamic>> getReports(String patientId) => _getReports.call(patientId);
}


