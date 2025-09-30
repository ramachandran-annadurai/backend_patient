class SymptomAnalysisModel {
  final String patientId;
  final String analysisText;
  final String? riskLevel;
  final String timestamp;

  SymptomAnalysisModel({
    required this.patientId,
    required this.analysisText,
    required this.timestamp,
    this.riskLevel,
  });

  factory SymptomAnalysisModel.fromJson(Map<String, dynamic> json) => SymptomAnalysisModel(
        patientId: (json['patient_id'] ?? '').toString(),
        analysisText: (json['analysis_text'] ?? json['result'] ?? '').toString(),
        timestamp: (json['timestamp'] ?? '').toString(),
        riskLevel: json['risk_level']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'analysis_text': analysisText,
        'timestamp': timestamp,
        if (riskLevel != null) 'risk_level': riskLevel,
      };
}


