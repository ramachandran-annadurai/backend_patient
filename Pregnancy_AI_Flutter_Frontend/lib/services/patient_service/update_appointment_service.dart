import '../../utils/constants.dart';
import '../core/base_api_provider.dart';

class UpdateAppointmentService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String appointmentId,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? appointmentStatus,
    String? notes,
  }) async {
    final update = <String, dynamic>{};
    if (appointmentDate != null) update['appointment_date'] = appointmentDate;
    if (appointmentTime != null) update['appointment_time'] = appointmentTime;
    if (appointmentType != null) update['appointment_type'] = appointmentType;
    if (appointmentStatus != null) update['appointment_status'] = appointmentStatus;
    if (notes != null) update['notes'] = notes;

    return await put(
      '${ApiConfig.doctorBaseUrl}/doctor/appointments/$appointmentId',
      update,
    );
  }
}


