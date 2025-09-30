class AppointmentModel {
  final String id;
  final String patientId;
  final String? patientName;
  final String appointmentDate;
  final String appointmentTime;
  final String? appointmentType;
  final String? status;
  final String? notes;
  final String? doctorId;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.patientName,
    this.appointmentType,
    this.status,
    this.notes,
    this.doctorId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? json['patientId'] ?? '').toString(),
      patientName: json['patient_name']?.toString(),
      appointmentDate: (json['appointment_date'] ?? '').toString(),
      appointmentTime: (json['appointment_time'] ?? '').toString(),
      appointmentType: json['appointment_type']?.toString(),
      status: json['status']?.toString() ?? json['appointment_status']?.toString(),
      notes: json['notes']?.toString(),
      doctorId: json['doctor_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      if (appointmentType != null) 'appointment_type': appointmentType,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (doctorId != null) 'doctor_id': doctorId,
    };
  }
}


