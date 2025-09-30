import '../services/core/network_request.dart';

class SymptomAnalysisResponseModel extends NetworkResponse {
  final bool success;
  final String analysisMethod;
  final String disclaimer;
  final int knowledgeBaseSuggestions;
  final int pregnancyWeek;
  final String primaryRecommendation;
  final List<String> redFlagsDetected;
  final String symptomText;
  final String timestamp;
  final String trimester;
  final List<String> additionalRecommendations;

  SymptomAnalysisResponseModel({
    required this.success,
    required this.analysisMethod,
    required this.disclaimer,
    required this.knowledgeBaseSuggestions,
    required this.pregnancyWeek,
    required this.primaryRecommendation,
    required this.redFlagsDetected,
    required this.symptomText,
    required this.timestamp,
    required this.trimester,
    required this.additionalRecommendations,
  }) : super.fromJson({});

  @override
  factory SymptomAnalysisResponseModel.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysisResponseModel(
      success: json['success'] ?? false,
      analysisMethod: json['analysis_method'] ?? '',
      disclaimer: json['disclaimer'] ?? '',
      knowledgeBaseSuggestions: json['knowledge_base_suggestions'] ?? 0,
      pregnancyWeek: json['pregnancy_week'] ?? 1,
      primaryRecommendation: json['primary_recommendation'] ?? '',
      redFlagsDetected: List<String>.from(json['red_flags_detected'] ?? []),
      symptomText: json['symptom_text'] ?? '',
      timestamp: json['timestamp'] ?? '',
      trimester: json['trimester'] ?? '',
      additionalRecommendations:
          List<String>.from(json['additional_recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'analysis_method': analysisMethod,
      'disclaimer': disclaimer,
      'knowledge_base_suggestions': knowledgeBaseSuggestions,
      'pregnancy_week': pregnancyWeek,
      'primary_recommendation': primaryRecommendation,
      'red_flags_detected': redFlagsDetected,
      'symptom_text': symptomText,
      'timestamp': timestamp,
      'trimester': trimester,
      'additional_recommendations': additionalRecommendations,
    };
  }

  @override
  String toString() {
    return 'SymptomAnalysisResponseModel(success: $success, analysisMethod: $analysisMethod, disclaimer: $disclaimer, knowledgeBaseSuggestions: $knowledgeBaseSuggestions, pregnancyWeek: $pregnancyWeek, primaryRecommendation: $primaryRecommendation, redFlagsDetected: $redFlagsDetected, symptomText: $symptomText, timestamp: $timestamp, trimester: $trimester, additionalRecommendations: $additionalRecommendations)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomAnalysisResponseModel &&
        other.success == success &&
        other.analysisMethod == analysisMethod &&
        other.disclaimer == disclaimer &&
        other.knowledgeBaseSuggestions == knowledgeBaseSuggestions &&
        other.pregnancyWeek == pregnancyWeek &&
        other.primaryRecommendation == primaryRecommendation &&
        other.redFlagsDetected == redFlagsDetected &&
        other.symptomText == symptomText &&
        other.timestamp == timestamp &&
        other.trimester == trimester &&
        other.additionalRecommendations == additionalRecommendations;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        analysisMethod.hashCode ^
        disclaimer.hashCode ^
        knowledgeBaseSuggestions.hashCode ^
        pregnancyWeek.hashCode ^
        primaryRecommendation.hashCode ^
        redFlagsDetected.hashCode ^
        symptomText.hashCode ^
        timestamp.hashCode ^
        trimester.hashCode ^
        additionalRecommendations.hashCode;
  }
}
