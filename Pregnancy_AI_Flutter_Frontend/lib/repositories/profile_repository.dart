import '../models/patient_profile_response.dart';
import '../services/patient_service/complete_profile_service.dart';
import '../services/patient_service/get_profile_service.dart';
import '../services/patient_service/complete_doctor_profile_service.dart';
import '../models/profile.dart';
import '../models/profile_api_response.dart';
import '../models/profile_complete_success_response.dart';

class ProfileRepository {
  final CompleteProfileService _completeProfile = CompleteProfileService();
  final GetProfileService _getProfile = GetProfileService();
  final CompleteDoctorProfileService _completeDoctorProfile =
      CompleteDoctorProfileService();

  Future<ProfileCompleteSuccessResponse> completeProfile({
    required String patientId,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String bloodType,
    required String weight,
    required String height,
    required bool isPregnant,
    String? lastPeriodDate,
    String? pregnancyWeek,
    String? expectedDeliveryDate,
    required String emergencyName,
    required String emergencyRelationship,
    required String emergencyPhone,
  }) {
    return _completeProfile.call(
      patientId: patientId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      bloodType: bloodType,
      weight: weight,
      height: height,
      isPregnant: isPregnant,
      lastPeriodDate: lastPeriodDate,
      pregnancyWeek: pregnancyWeek,
      expectedDeliveryDate: expectedDeliveryDate,
      emergencyName: emergencyName,
      emergencyRelationship: emergencyRelationship,
      emergencyPhone: emergencyPhone,
    );
  }

  Future<PatientProfileResponse> getProfile({required String patientId}) {
    return _getProfile.call(patientId: patientId);
  }
}
