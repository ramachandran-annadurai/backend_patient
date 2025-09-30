class SymptomAnalysisRequestModel {
  final String text;
  final String patientId;
  final int weeksPregnant;
  final String severity;
  final String? notes;
  final String? transcribedText;
  final String date;
  final String userRole;
  final PatientContext patientContext;

  SymptomAnalysisRequestModel({
    required this.text,
    required this.patientId,
    required this.weeksPregnant,
    required this.severity,
    this.notes,
    this.transcribedText,
    required this.date,
    required this.userRole,
    required this.patientContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'patient_id': patientId,
      'weeks_pregnant': weeksPregnant,
      'severity': severity,
      'notes': notes,
      'transcribed_text': transcribedText,
      'date': date,
      'userRole': userRole,
      'patient_context': patientContext.toJson(),
    };
  }

  factory SymptomAnalysisRequestModel.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysisRequestModel(
      text: json['text'] ?? '',
      patientId: json['patient_id'] ?? '',
      weeksPregnant: json['weeks_pregnant'] ?? 1,
      severity: json['severity'] ?? '',
      notes: json['notes'],
      transcribedText: json['transcribed_text'],
      date: json['date'] ?? '',
      userRole: json['userRole'] ?? 'patient',
      patientContext: PatientContext.fromJson(json['patient_context'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'SymptomAnalysisRequestModel(text: $text, patientId: $patientId, weeksPregnant: $weeksPregnant, severity: $severity, notes: $notes, transcribedText: $transcribedText, date: $date, userRole: $userRole, patientContext: $patientContext)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomAnalysisRequestModel &&
        other.text == text &&
        other.patientId == patientId &&
        other.weeksPregnant == weeksPregnant &&
        other.severity == severity &&
        other.notes == notes &&
        other.transcribedText == transcribedText &&
        other.date == date &&
        other.userRole == userRole &&
        other.patientContext == patientContext;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        patientId.hashCode ^
        weeksPregnant.hashCode ^
        severity.hashCode ^
        notes.hashCode ^
        transcribedText.hashCode ^
        date.hashCode ^
        userRole.hashCode ^
        patientContext.hashCode;
  }
}

class PatientContext {
  final int pregnancyWeek;
  final String trimester;
  final String symptomDate;
  final String severityLevel;
  final String? additionalNotes;

  PatientContext({
    required this.pregnancyWeek,
    required this.trimester,
    required this.symptomDate,
    required this.severityLevel,
    this.additionalNotes,
  });

  factory PatientContext.fromJson(Map<String, dynamic> json) {
    return PatientContext(
      pregnancyWeek: json['pregnancy_week'] ?? 1,
      trimester: json['trimester'] ?? '',
      symptomDate: json['symptom_date'] ?? '',
      severityLevel: json['severity_level'] ?? '',
      additionalNotes: json['additional_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pregnancy_week': pregnancyWeek,
      'trimester': trimester,
      'symptom_date': symptomDate,
      'severity_level': severityLevel,
      'additional_notes': additionalNotes,
    };
  }

  @override
  String toString() {
    return 'PatientContext(pregnancyWeek: $pregnancyWeek, trimester: $trimester, symptomDate: $symptomDate, severityLevel: $severityLevel, additionalNotes: $additionalNotes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientContext &&
        other.pregnancyWeek == pregnancyWeek &&
        other.trimester == trimester &&
        other.symptomDate == symptomDate &&
        other.severityLevel == severityLevel &&
        other.additionalNotes == additionalNotes;
  }

  @override
  int get hashCode {
    return pregnancyWeek.hashCode ^
        trimester.hashCode ^
        symptomDate.hashCode ^
        severityLevel.hashCode ^
        additionalNotes.hashCode;
  }
}
