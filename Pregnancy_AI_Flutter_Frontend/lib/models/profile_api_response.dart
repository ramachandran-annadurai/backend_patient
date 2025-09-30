import 'profile.dart';

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
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
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

class ProfileApiResponse {
  final int age;
  final String bloodType;
  final String email;
  final EmergencyContact emergencyContact;
  final String expectedDeliveryDate;
  final String firstName;
  final bool isPregnant;
  final String lastName;
  final String lastPeriodDate;
  final String mobile;
  final String patientId;
  final dynamic preferences;
  final int pregnancyWeek;
  final String username;

  ProfileApiResponse({
    required this.age,
    required this.bloodType,
    required this.email,
    required this.emergencyContact,
    required this.expectedDeliveryDate,
    required this.firstName,
    required this.isPregnant,
    required this.lastName,
    required this.lastPeriodDate,
    required this.mobile,
    required this.patientId,
    this.preferences,
    required this.pregnancyWeek,
    required this.username,
  });

  factory ProfileApiResponse.fromJson(Map<String, dynamic> json) {
    return ProfileApiResponse(
      age: json['age'] ?? 0,
      bloodType: json['blood_type']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emergencyContact: json['emergency_contact'] != null
          ? EmergencyContact.fromJson(
              json['emergency_contact'] as Map<String, dynamic>)
          : EmergencyContact(name: '', phone: '', relationship: ''),
      expectedDeliveryDate: json['expected_delivery_date']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      isPregnant: json['is_pregnant'] == true,
      lastName: json['last_name']?.toString() ?? '',
      lastPeriodDate: json['last_period_date']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      preferences: json['preferences'],
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      username: json['username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'blood_type': bloodType,
      'email': email,
      'emergency_contact': emergencyContact.toJson(),
      'expected_delivery_date': expectedDeliveryDate,
      'first_name': firstName,
      'is_pregnant': isPregnant,
      'last_name': lastName,
      'last_period_date': lastPeriodDate,
      'mobile': mobile,
      'patient_id': patientId,
      'preferences': preferences,
      'pregnancy_week': pregnancyWeek,
      'username': username,
    };
  }

  // Transform API response to domain model
  ProfileModel toDomainModel() {
    return ProfileModel(
      userId: patientId,
      firstName: firstName.isNotEmpty ? firstName : null,
      lastName: lastName.isNotEmpty ? lastName : null,
      dateOfBirth: _calculateDateOfBirth(),
      bloodType: bloodType.isNotEmpty ? bloodType : null,
      weight: null, // Not provided by API
      height: null, // Not provided by API
      isPregnant: isPregnant,
      lastPeriodDate: lastPeriodDate.isNotEmpty ? lastPeriodDate : null,
      pregnancyWeek: pregnancyWeek > 0 ? pregnancyWeek.toString() : null,
      expectedDeliveryDate:
          expectedDeliveryDate.isNotEmpty ? expectedDeliveryDate : null,
      emergencyName:
          emergencyContact.name.isNotEmpty ? emergencyContact.name : null,
      emergencyRelationship: emergencyContact.relationship.isNotEmpty
          ? emergencyContact.relationship
          : null,
      emergencyPhone:
          emergencyContact.phone.isNotEmpty ? emergencyContact.phone : null,
    );
  }

  // Helper method to calculate approximate date of birth from age
  String? _calculateDateOfBirth() {
    if (age <= 0) return null;

    final now = DateTime.now();
    final birthYear = now.year - age;
    // Use January 1st as approximate birth date
    return '$birthYear-01-01';
  }
}
