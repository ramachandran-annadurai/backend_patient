class ProfileModel  {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? bloodType;
  final String? weight;
  final String? height;
  final bool? isPregnant;
  final String? lastPeriodDate;
  final String? pregnancyWeek;
  final String? expectedDeliveryDate;
  final String? emergencyName;
  final String? emergencyRelationship;
  final String? emergencyPhone;

  ProfileModel({
    required this.userId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.bloodType,
    this.weight,
    this.height,
    this.isPregnant,
    this.lastPeriodDate,
    this.pregnancyWeek,
    this.expectedDeliveryDate,
    this.emergencyName,
    this.emergencyRelationship,
    this.emergencyPhone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: (json['userId'] ?? json['patient_id'] ?? json['_id'] ?? '').toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      bloodType: json['blood_type']?.toString(),
      weight: json['weight']?.toString(),
      height: json['height']?.toString(),
      isPregnant: json['is_pregnant'] is bool ? json['is_pregnant'] : null,
      lastPeriodDate: json['last_period_date']?.toString(),
      pregnancyWeek: json['pregnancy_week']?.toString(),
      expectedDeliveryDate: json['expected_delivery_date']?.toString(),
      emergencyName: json['emergency_name']?.toString(),
      emergencyRelationship: json['emergency_relationship']?.toString(),
      emergencyPhone: json['emergency_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (bloodType != null) 'blood_type': bloodType,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (isPregnant != null) 'is_pregnant': isPregnant,
      if (lastPeriodDate != null) 'last_period_date': lastPeriodDate,
      if (pregnancyWeek != null) 'pregnancy_week': pregnancyWeek,
      if (expectedDeliveryDate != null) 'expected_delivery_date': expectedDeliveryDate,
      if (emergencyName != null) 'emergency_name': emergencyName,
      if (emergencyRelationship != null) 'emergency_relationship': emergencyRelationship,
      if (emergencyPhone != null) 'emergency_phone': emergencyPhone,
    };
  }
}


