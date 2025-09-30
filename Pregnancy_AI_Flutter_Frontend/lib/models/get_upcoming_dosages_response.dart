import '../services/core/network_request.dart';

/// Response model for Get Upcoming Dosages API
class GetUpcomingDosagesResponseModel extends NetworkResponse {
  final bool success;
  final String patientId;
  final String currentTime; // ISO timestamp
  final int totalUpcoming;
  final int totalPrescriptions;
  final List<Map<String, dynamic>> upcomingDosages;
  final List<Map<String, dynamic>> prescriptionMedications;

  GetUpcomingDosagesResponseModel({
    required this.success,
    required this.patientId,
    required this.currentTime,
    required this.totalUpcoming,
    required this.totalPrescriptions,
    required this.upcomingDosages,
    required this.prescriptionMedications,
  }) : super.fromJson({});

  @override
  factory GetUpcomingDosagesResponseModel.fromJson(Map<String, dynamic> json) {
    return GetUpcomingDosagesResponseModel(
      success: (json['success'] ?? false) == true,
      patientId: (json['patientId'] ?? json['patient_id'] ?? '').toString(),
      currentTime: (json['current_time'] ?? '').toString(),
      totalUpcoming:
          int.tryParse(json['total_upcoming']?.toString() ?? '0') ?? 0,
      totalPrescriptions:
          int.tryParse(json['total_prescriptions']?.toString() ?? '0') ?? 0,
      upcomingDosages: ((json['upcoming_dosages'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      prescriptionMedications:
          ((json['prescription_medications'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'patientId': patientId,
      'current_time': currentTime,
      'total_upcoming': totalUpcoming,
      'total_prescriptions': totalPrescriptions,
      'upcoming_dosages': upcomingDosages,
      'prescription_medications': prescriptionMedications,
    };
  }
}
