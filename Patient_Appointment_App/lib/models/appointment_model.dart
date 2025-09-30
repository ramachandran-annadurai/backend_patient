class AppointmentModel {
  final String? id;
  final String? patientId;
  final String? patientName;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentType;
  final String? status;
  final String? notes;
  final String? patientNotes;
  final String? doctorId;
  final String? createdAt;
  final String? updatedAt;
  final String? requestedBy;

  AppointmentModel({
    this.id,
    this.patientId,
    this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentType,
    this.status,
    this.notes,
    this.patientNotes,
    this.doctorId,
    this.createdAt,
    this.updatedAt,
    this.requestedBy,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['appointment_id']?.toString(),
      patientId: json['patient_id']?.toString(),
      patientName: json['patient_name']?.toString(),
      appointmentDate: json['appointment_date']?.toString() ?? '',
      appointmentTime: json['appointment_time']?.toString() ?? '',
      appointmentType: json['appointment_type']?.toString() ?? '',
      status:
          json['appointment_status']?.toString() ?? json['status']?.toString(),
      notes: json['notes']?.toString(),
      patientNotes: json['patient_notes']?.toString(),
      doctorId: json['doctor_id']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      requestedBy: json['requested_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'appointment_id': id,
      if (patientId != null) 'patient_id': patientId,
      if (patientName != null) 'patient_name': patientName,
      'appointment_date': appointmentDate,
      'appointment_time': appointmentTime,
      'appointment_type': appointmentType,
      if (status != null) 'appointment_status': status,
      if (notes != null) 'notes': notes,
      if (patientNotes != null) 'patient_notes': patientNotes,
      if (doctorId != null) 'doctor_id': doctorId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (requestedBy != null) 'requested_by': requestedBy,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? status,
    String? notes,
    String? patientNotes,
    String? doctorId,
    String? createdAt,
    String? updatedAt,
    String? requestedBy,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      patientNotes: patientNotes ?? this.patientNotes,
      doctorId: doctorId ?? this.doctorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      requestedBy: requestedBy ?? this.requestedBy,
    );
  }
}
