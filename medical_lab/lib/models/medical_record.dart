class MedicalRecord {
  final String? medicalConditions;
  final String? allergies;
  final String? currentMedications;
  final String? previousPregnancies;
  final String? familyHealthHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MedicalRecord({
    this.medicalConditions,
    this.allergies,
    this.currentMedications,
    this.previousPregnancies,
    this.familyHealthHistory,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'previousPregnancies': previousPregnancies,
      'familyHealthHistory': familyHealthHistory,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      medicalConditions: json['medicalConditions'],
      allergies: json['allergies'],
      currentMedications: json['currentMedications'],
      previousPregnancies: json['previousPregnancies'],
      familyHealthHistory: json['familyHealthHistory'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  MedicalRecord copyWith({
    String? medicalConditions,
    String? allergies,
    String? currentMedications,
    String? previousPregnancies,
    String? familyHealthHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecord(
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      familyHealthHistory: familyHealthHistory ?? this.familyHealthHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
