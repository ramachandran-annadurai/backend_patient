import 'dart:convert';
import 'package:http/http.dart' as http;
// No ApiCore required; this posts to N8N directly
import '../../config/n8n_config.dart';

class ProcessPrescriptionWithN8NService {
  Future<Map<String, dynamic>> call(Map<String, dynamic> prescriptionData) async {
    try {
      final String n8nWebhookUrl = N8NConfig.getWebhookUrl('prescription');

      if (!N8NConfig.isConfigured) {
        return {
          'error': 'N8N webhook not configured. Please update n8n_config.dart with your webhook URLs.',
          'step': 'configuration_error'
        };
      }

      print('🔍 Processing Prescription with N8N:');
      print('🔍 N8N Webhook URL: $n8nWebhookUrl');
      print('🔍 Data: $prescriptionData');

      final response = await http.post(
        Uri.parse(n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(prescriptionData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('🔍 N8N Processing Successful: $result');
        return result;
      } else {
        print('❌ N8N API Error: ${response.statusCode} - ${response.body}');
        return {'error': 'N8N API Error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ N8N Network Error: $e');
      return {'error': 'N8N Network error: $e'};
    }
  }
}
