import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';
import '../core/base_api_provider.dart';


class ApiLoginService extends BaseApiProvider {
  Future<Map<String, dynamic>> call({
    required String loginIdentifier,
    required String password,
    required String role,
  }) async {
    int retryCount = 0;
    const int maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        String endpoint;
        Map<String, dynamic> requestBody;

        if (role == 'doctor') {
          endpoint = '${ApiConfig.doctorBaseUrl}/doctor-login';
          requestBody = {
            'email': loginIdentifier,
            'password': password,
          };
          print('🔍 Doctor Login API Call (Attempt ${retryCount + 1}):');
          print('🔍 URL: $endpoint');
          print('🔍 Email: $loginIdentifier (using doctor backend - doctor_v2 collection)');
        } else {
          endpoint = '${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}';
          requestBody = {
            'login_identifier': loginIdentifier,
            'password': password,
            'role': role,
          };
          print('🔍 Patient Login API Call (Attempt ${retryCount + 1}):');
          print('🔍 URL: $endpoint');
          print('🔍 Login Identifier: $loginIdentifier (using patient backend - patients_v2 collection)');
        }

        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: ApiCore.headers,
              body: json.encode(requestBody),
            )
            .timeout(ApiCore.defaultTimeout, onTimeout: () {
          throw TimeoutException('Login request timed out after ${ApiCore.defaultTimeout.inSeconds} seconds');
        });

        print('🔍 ${role == 'doctor' ? 'Doctor' : 'Patient'} Login Response Status: ${response.statusCode}');
        print('🔍 ${role == 'doctor' ? 'Doctor' : 'Patient'} Login Response Body: ${response.body}');

        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode >= 500 && retryCount < maxRetries - 1) {
          retryCount++;
          print('⚠️ Server error ${response.statusCode}, retrying in ${retryCount * 2} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        } else {
          return json.decode(response.body);
        }
      } on TimeoutException catch (e) {
        retryCount++;
        print('⏰ Login timeout (attempt $retryCount): $e');
        if (retryCount >= maxRetries) {
          return {'error': 'Login request timed out. Please check your internet connection and try again.'};
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      } catch (e) {
        retryCount++;
        print('❌ ${role == 'doctor' ? 'Doctor' : 'Patient'} login network error (attempt $retryCount): $e');
        if (retryCount >= maxRetries) {
          return {'error': 'Network error: $e. Please check your internet connection and try again.'};
        }
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }

    return {'error': 'Login failed after $maxRetries attempts'};
  }
}
