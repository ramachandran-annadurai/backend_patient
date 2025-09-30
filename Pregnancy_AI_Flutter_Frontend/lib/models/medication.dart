class MedicationLogModel {
  final String patientId;
  final String medicationName;
  final String dosage;
  final String? notes;
  final String timestamp;

  MedicationLogModel({
    required this.patientId,
    required this.medicationName,
    required this.dosage,
    required this.timestamp,
    this.notes,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) => MedicationLogModel(
        patientId: (json['patient_id'] ?? '').toString(),
        medicationName: (json['medication_name'] ?? '').toString(),
        dosage: (json['dosage'] ?? '').toString(),
        timestamp: (json['timestamp'] ?? '').toString(),
        notes: json['notes']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'medication_name': medicationName,
        'dosage': dosage,
        'timestamp': timestamp,
        if (notes != null) 'notes': notes,
      };
}

class PrescriptionModel {
  final String id;
  final String patientId;
  final String medicationName;
  final String? status;
  final String? filename;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.medicationName,
    this.status,
    this.filename,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) => PrescriptionModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        patientId: (json['patient_id'] ?? '').toString(),
        medicationName: (json['medication_name'] ?? '').toString(),
        status: json['status']?.toString(),
        filename: json['filename']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'medication_name': medicationName,
        if (status != null) 'status': status,
        if (filename != null) 'filename': filename,
      };
}

class TabletTrackingEntryModel {
  final String patientId;
  final String date;
  final String medicationName;
  final bool taken;

  TabletTrackingEntryModel({
    required this.patientId,
    required this.date,
    required this.medicationName,
    required this.taken,
  });

  factory TabletTrackingEntryModel.fromJson(Map<String, dynamic> json) => TabletTrackingEntryModel(
        patientId: (json['patient_id'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
        medicationName: (json['medication_name'] ?? '').toString(),
        taken: json['taken'] == true,
      );

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'date': date,
        'medication_name': medicationName,
        'taken': taken,
      };
}


