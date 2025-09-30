import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class CompleteDoctorProfileService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String firstName,
    required String lastName,
    required String qualification,
    required String specialization,
    required String workingHospital,
    required String doctorId,
    required String licenseNumber,
    required String phone,
    required String address,
    required String city,
    required String state,
    required String zipCode,
    required String experienceYears,
  }) async {
    try {
      final response = await post(
        '${ApiConfig.doctorBaseUrl}${ApiConfig.completeDoctorProfileEndpoint}',
        {
          'first_name': firstName,
          'last_name': lastName,
          'qualification': qualification,
          'specialization': specialization,
          'working_hospital': workingHospital,
          'doctor_id': doctorId,
          'license_number': licenseNumber,
          'phone': phone,
          'address': address,
          'city': city,
          'state': state,
          'zip_code': zipCode,
          'experience_years': experienceYears,
        },
      );
      return response;
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}
