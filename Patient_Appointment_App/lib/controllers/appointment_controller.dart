import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../models/api_response_model.dart';
import '../services/api_service.dart';

class AppointmentController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> _appointmentHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;
  List<AppointmentModel> get appointmentHistory => _appointmentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  // Create appointment
  Future<bool> createAppointment({
    required String appointmentDate,
    required String appointmentTime,
    required String appointmentType,
    String? notes,
    String? patientNotes,
    String? doctorId,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.createAppointment(
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: appointmentType,
        notes: notes,
        patientNotes: patientNotes,
        doctorId: doctorId,
      );

      _setLoading(false);

      if (response.success) {
        // Refresh appointments list
        await getAppointments();
        return true;
      } else {
        _setError(response.error ?? 'Failed to create appointment');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }

  // Get appointments
  Future<void> getAppointments({
    String? date,
    String? status,
    String? appointmentType,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.getAppointments(
        date: date,
        status: status,
        appointmentType: appointmentType,
      );

      _setLoading(false);

      if (response.success && response.data != null) {
        _appointments = response.data!;
      } else {
        _setError(response.error ?? 'Failed to load appointments');
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // Update appointment
  Future<bool> updateAppointment({
    required String appointmentId,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? notes,
    String? patientNotes,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.updateAppointment(
        appointmentId: appointmentId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        appointmentType: appointmentType,
        notes: notes,
        patientNotes: patientNotes,
      );

      _setLoading(false);

      if (response.success) {
        // Refresh appointments list
        await getAppointments();
        return true;
      } else {
        _setError(response.error ?? 'Failed to update appointment');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.cancelAppointment(appointmentId);

      _setLoading(false);

      if (response.success) {
        // Refresh appointments list
        await getAppointments();
        return true;
      } else {
        _setError(response.error ?? 'Failed to cancel appointment');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    }
  }

  // Get upcoming appointments
  Future<void> getUpcomingAppointments() async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.getUpcomingAppointments();

      _setLoading(false);

      if (response.success && response.data != null) {
        _upcomingAppointments = response.data!;
      } else {
        _setError(response.error ?? 'Failed to load upcoming appointments');
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // Get appointment history
  Future<void> getAppointmentHistory() async {
    _setLoading(true);
    clearError();

    try {
      final response = await _apiService.getAppointmentHistory();

      _setLoading(false);

      if (response.success && response.data != null) {
        _appointmentHistory = response.data!;
      } else {
        _setError(response.error ?? 'Failed to load appointment history');
      }
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      getAppointments(),
      getUpcomingAppointments(),
      getAppointmentHistory(),
    ]);
  }
}
