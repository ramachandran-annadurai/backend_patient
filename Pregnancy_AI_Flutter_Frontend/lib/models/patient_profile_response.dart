import '../services/core/network_request.dart';

class PatientProfileResponse extends NetworkResponse {
  final String message;
  final PatientProfile profile;
  final bool success;

  PatientProfileResponse({
    required this.message,
    required this.profile,
    required this.success,
  }) : super.fromJson({});

  factory PatientProfileResponse.fromJson(Map<String, dynamic> json) {
    return PatientProfileResponse(
      message: json['message'] ?? '',
      profile: PatientProfile.fromJson(json['profile'] ?? {}),
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'profile': profile.toJson(),
      'success': success,
    };
  }
}

class PatientProfile {
  final int? age;
  final String bloodType;
  final String createdAt;
  final String dateOfBirth;
  final String email;
  final bool emailVerified;
  final EmergencyContact emergencyContact;
  final String expectedDeliveryDate;
  final String firstName;
  final String height;
  final bool isPregnant;
  final String lastName;
  final String lastPeriodDate;
  final String lastUpdated;
  final String mobile;
  final String? passwordUpdatedAt;
  final String patientId;
  final int pregnancyWeek;
  final String profileCompletedAt;
  final String status;
  final String username;
  final String verifiedAt;
  final String weight;

  PatientProfile({
    this.age,
    required this.bloodType,
    required this.createdAt,
    required this.dateOfBirth,
    required this.email,
    required this.emailVerified,
    required this.emergencyContact,
    required this.expectedDeliveryDate,
    required this.firstName,
    required this.height,
    required this.isPregnant,
    required this.lastName,
    required this.lastPeriodDate,
    required this.lastUpdated,
    required this.mobile,
    this.passwordUpdatedAt,
    required this.patientId,
    required this.pregnancyWeek,
    required this.profileCompletedAt,
    required this.status,
    required this.username,
    required this.verifiedAt,
    required this.weight,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      age: json['age'],
      bloodType: json['blood_type'] ?? '',
      createdAt: json['created_at'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      emergencyContact:
          EmergencyContact.fromJson(json['emergency_contact'] ?? {}),
      expectedDeliveryDate: json['expected_delivery_date'] ?? '',
      firstName: json['first_name'] ?? '',
      height: json['height'] ?? '',
      isPregnant: json['is_pregnant'] ?? false,
      lastName: json['last_name'] ?? '',
      lastPeriodDate: json['last_period_date'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      mobile: json['mobile'] ?? '',
      passwordUpdatedAt: json['password_updated_at'],
      patientId: json['patient_id'] ?? '',
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      profileCompletedAt: json['profile_completed_at'] ?? '',
      status: json['status'] ?? '',
      username: json['username'] ?? '',
      verifiedAt: json['verified_at'] ?? '',
      weight: json['weight'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'blood_type': bloodType,
      'created_at': createdAt,
      'date_of_birth': dateOfBirth,
      'email': email,
      'email_verified': emailVerified,
      'emergency_contact': emergencyContact.toJson(),
      'expected_delivery_date': expectedDeliveryDate,
      'first_name': firstName,
      'height': height,
      'is_pregnant': isPregnant,
      'last_name': lastName,
      'last_period_date': lastPeriodDate,
      'last_updated': lastUpdated,
      'mobile': mobile,
      'password_updated_at': passwordUpdatedAt,
      'patient_id': patientId,
      'pregnancy_week': pregnancyWeek,
      'profile_completed_at': profileCompletedAt,
      'status': status,
      'username': username,
      'verified_at': verifiedAt,
      'weight': weight,
    };
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}
