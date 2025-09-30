import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
// This endpoint uses content-type only; no auth headers needed

class SendOtpService {
  Future<Map<String, dynamic>> call({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendOtpEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }
}
