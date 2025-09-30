import '../services/patient_service/get_appointments_service.dart';
import '../services/patient_service/create_appointment_service.dart';
import '../services/patient_service/update_appointment_service.dart';
import '../services/patient_service/delete_appointment_service.dart';
import '../models/appointment.dart';

class AppointmentsRepository {
  final GetAppointmentsService _getAppointments = GetAppointmentsService();
  final CreateAppointmentService _createAppointment = CreateAppointmentService();
  final UpdateAppointmentService _updateAppointment = UpdateAppointmentService();
  final DeleteAppointmentService _deleteAppointment = DeleteAppointmentService();

  Future<Map<String, dynamic>> getAppointments({String? patientId, String? date, String? status}) =>
      _getAppointments.call(patientId: patientId, date: date, status: status);

  Future<List<AppointmentModel>> getAppointmentsAsModels({String? patientId, String? date, String? status}) async {
    final res = await _getAppointments.call(patientId: patientId, date: date, status: status);
    if (res.containsKey('error')) {
      throw Exception(res['error'].toString());
    }
    final list = (res['appointments'] ?? res['items'] ?? res['data'] ?? []) as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => AppointmentModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> createAppointment({
    required String patientId,
    required String appointmentDate,
    required String appointmentTime,
    String? appointmentType,
    String? notes,
    String? doctorId,
  }) => _createAppointment.call(
        patientId: patientId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: appointmentType,
        notes: notes,
        doctorId: doctorId,
      );

  Future<AppointmentModel> createAppointmentAsModel({
    required String patientId,
    required String appointmentDate,
    required String appointmentTime,
    String? appointmentType,
    String? notes,
    String? doctorId,
  }) async {
    final res = await _createAppointment.call(
      patientId: patientId,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      appointmentType: appointmentType,
      notes: notes,
      doctorId: doctorId,
    );
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final obj = (res['appointment'] is Map<String, dynamic>) ? res['appointment'] as Map<String, dynamic> : res;
    return AppointmentModel.fromJson(obj);
  }

  Future<Map<String, dynamic>> updateAppointment({
    required String appointmentId,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? appointmentStatus,
    String? notes,
  }) => _updateAppointment.call(
        appointmentId: appointmentId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: appointmentType,
        appointmentStatus: appointmentStatus,
        notes: notes,
      );

  Future<AppointmentModel> updateAppointmentAsModel({
    required String appointmentId,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? appointmentStatus,
    String? notes,
  }) async {
    final res = await _updateAppointment.call(
      appointmentId: appointmentId,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      appointmentType: appointmentType,
      appointmentStatus: appointmentStatus,
      notes: notes,
    );
    if (res.containsKey('error')) throw Exception(res['error'].toString());
    final obj = (res['appointment'] is Map<String, dynamic>) ? res['appointment'] as Map<String, dynamic> : res;
    return AppointmentModel.fromJson(obj);
  }

  Future<Map<String, dynamic>> deleteAppointment(String appointmentId) =>
      _deleteAppointment.call(appointmentId);
}


