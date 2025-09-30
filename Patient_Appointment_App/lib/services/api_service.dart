import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';
import '../models/api_response_model.dart';

class ApiService {
  static const String baseUrl = 'https://pregnancy-ai.onrender.com';
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Generic HTTP methods
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = {..._headers, ...?headers};

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await http.get(url, headers: requestHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'PUT':
          response = await http
              .put(url, headers: requestHeaders, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response =
              await http.delete(url, headers: requestHeaders).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        return {
          'error': responseData['error'] ??
              'Request failed with status ${response.statusCode}',
          'success': false,
        };
      }
    } catch (e) {
      return {
        'error': 'Network error: $e',
        'success': false,
      };
    }
  }

  // Appointment CRUD operations
  Future<ApiResponseModel<AppointmentModel>> createAppointment({
    required String appointmentDate,
    required String appointmentTime,
    required String appointmentType,
    String? notes,
    String? patientNotes,
    String? doctorId,
  }) async {
    final response = await _makeRequest(
      'POST',
      '/patient/appointments',
      body: {
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'appointment_type': appointmentType,
        if (notes != null) 'notes': notes,
        if (patientNotes != null) 'patient_notes': patientNotes,
        if (doctorId != null) 'doctor_id': doctorId,
      },
    );

    if (response.containsKey('error')) {
      return ApiResponseModel<AppointmentModel>(
        success: false,
        error: response['error'],
      );
    }

    return ApiResponseModel<AppointmentModel>(
      success: true,
      data: AppointmentModel.fromJson(response),
      message: response['message'],
    );
  }

  Future<ApiResponseModel<List<AppointmentModel>>> getAppointments({
    String? date,
    String? status,
    String? appointmentType,
  }) async {
    String endpoint = '/patient/appointments';
    List<String> queryParams = [];

    if (date != null) queryParams.add('date=$date');
    if (status != null) queryParams.add('status=$status');
    if (appointmentType != null)
      queryParams.add('appointment_type=$appointmentType');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _makeRequest('GET', endpoint);

    if (response.containsKey('error')) {
      return ApiResponseModel<List<AppointmentModel>>(
        success: false,
        error: response['error'],
      );
    }

    final appointments = (response['appointments'] as List?)
            ?.map((json) => AppointmentModel.fromJson(json))
            .toList() ??
        [];

    return ApiResponseModel<List<AppointmentModel>>(
      success: true,
      data: appointments,
      message: response['message'],
    );
  }

  Future<ApiResponseModel<AppointmentModel>> updateAppointment({
    required String appointmentId,
    String? appointmentDate,
    String? appointmentTime,
    String? appointmentType,
    String? notes,
    String? patientNotes,
  }) async {
    Map<String, dynamic> body = {};
    if (appointmentDate != null) body['appointment_date'] = appointmentDate;
    if (appointmentTime != null) body['appointment_time'] = appointmentTime;
    if (appointmentType != null) body['appointment_type'] = appointmentType;
    if (notes != null) body['notes'] = notes;
    if (patientNotes != null) body['patient_notes'] = patientNotes;

    final response = await _makeRequest(
      'PUT',
      '/patient/appointments/$appointmentId',
      body: body,
    );

    if (response.containsKey('error')) {
      return ApiResponseModel<AppointmentModel>(
        success: false,
        error: response['error'],
      );
    }

    return ApiResponseModel<AppointmentModel>(
      success: true,
      message: response['message'],
    );
  }

  Future<ApiResponseModel<void>> cancelAppointment(String appointmentId) async {
    final response =
        await _makeRequest('DELETE', '/patient/appointments/$appointmentId');

    if (response.containsKey('error')) {
      return ApiResponseModel<void>(
        success: false,
        error: response['error'],
      );
    }

    return ApiResponseModel<void>(
      success: true,
      message: response['message'],
    );
  }

  Future<ApiResponseModel<List<AppointmentModel>>>
      getUpcomingAppointments() async {
    final response =
        await _makeRequest('GET', '/patient/appointments/upcoming');

    if (response.containsKey('error')) {
      return ApiResponseModel<List<AppointmentModel>>(
        success: false,
        error: response['error'],
      );
    }

    final appointments = (response['upcoming_appointments'] as List?)
            ?.map((json) => AppointmentModel.fromJson(json))
            .toList() ??
        [];

    return ApiResponseModel<List<AppointmentModel>>(
      success: true,
      data: appointments,
      message: response['message'],
    );
  }

  Future<ApiResponseModel<List<AppointmentModel>>>
      getAppointmentHistory() async {
    final response = await _makeRequest('GET', '/patient/appointments/history');

    if (response.containsKey('error')) {
      return ApiResponseModel<List<AppointmentModel>>(
        success: false,
        error: response['error'],
      );
    }

    final appointments = (response['appointment_history'] as List?)
            ?.map((json) => AppointmentModel.fromJson(json))
            .toList() ??
        [];

    return ApiResponseModel<List<AppointmentModel>>(
      success: true,
      data: appointments,
      message: response['message'],
    );
  }
}
