import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class DeleteAppointmentService extends BaseApiProvider {
  Future<Map<String, dynamic>> call(String appointmentId) async {
    return await delete(
      '${ApiConfig.doctorBaseUrl}/doctor/appointments/$appointmentId',
    );
  }
}


