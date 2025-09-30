import 'package:flutter/foundation.dart';

/// Request model for saving a medication log
class SaveMedicationLogRequest {
  final String patientId;
  final String medicationName;
  final List<MedicationDosageItem> dosages;
  final String dateTaken;
  final String? notes;
  final String? prescribedBy;
  final String medicationType; // e.g., "prescription" | "otc"
  final int pregnancyWeek;

  const SaveMedicationLogRequest({
    required this.patientId,
    required this.medicationName,
    required this.dosages,
    required this.dateTaken,
    this.notes,
    this.prescribedBy,
    required this.medicationType,
    required this.pregnancyWeek,
  });

  factory SaveMedicationLogRequest.fromJson(Map<String, dynamic> json) {
    return SaveMedicationLogRequest(
      patientId: (json['patient_id'] ?? '').toString(),
      medicationName: (json['medication_name'] ?? '').toString(),
      dosages: ((json['dosages'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MedicationDosageItem.fromJson)
          .toList(),
      dateTaken: (json['date_taken'] ?? '').toString(),
      notes: json['notes']?.toString(),
      prescribedBy: json['prescribed_by']?.toString(),
      medicationType: (json['medication_type'] ?? '').toString(),
      pregnancyWeek:
          int.tryParse(json['pregnancy_week']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'medication_name': medicationName,
      'dosages': dosages.map((d) => d.toJson()).toList(),
      'date_taken': dateTaken,
      if (notes != null) 'notes': notes,
      if (prescribedBy != null) 'prescribed_by': prescribedBy,
      'medication_type': medicationType,
      'pregnancy_week': pregnancyWeek,
    };
  }
}

/// Nested dosage item in the medication save request
class MedicationDosageItem {
  final String dosage; // e.g., "2tablet"
  final String time; // e.g., "17:09 PM"
  final String frequency; // e.g., "Once"
  final bool reminderEnabled;
  final String? nextDoseTime; // can be null
  final String? specialInstructions; // e.g., "before food"

  const MedicationDosageItem({
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.reminderEnabled,
    this.nextDoseTime,
    this.specialInstructions,
  });

  factory MedicationDosageItem.fromJson(Map<String, dynamic> json) {
    return MedicationDosageItem(
      dosage: (json['dosage'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      frequency: (json['frequency'] ?? '').toString(),
      reminderEnabled: (json['reminder_enabled'] ?? false) == true,
      nextDoseTime: json['next_dose_time']?.toString(),
      specialInstructions: json['special_instructions']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dosage': dosage,
      'time': time,
      'frequency': frequency,
      'reminder_enabled': reminderEnabled,
      'next_dose_time': nextDoseTime,
      'special_instructions': specialInstructions,
    };
  }
}
