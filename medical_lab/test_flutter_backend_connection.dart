import 'dart:io';
import 'package:dio/dio.dart';

/// Test script to verify Flutter app can connect to PaddleOCR backend
/// Run with: dart test_flutter_backend_connection.dart

void main() async {
  print('🧪 Testing Flutter-Backend Connection...\n');
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  try {
    // Test 1: Health Check
    print('1️⃣ Testing health check...');
    final healthResponse = await dio.get('/health');
    print('✅ Health check passed: ${healthResponse.statusCode}');
    print('   Response: ${healthResponse.data}\n');

    // Test 2: Supported Formats
    print('2️⃣ Testing supported formats...');
    final formatsResponse = await dio.get('/ocr/enhanced/formats');
    print('✅ Supported formats retrieved: ${formatsResponse.statusCode}');
    print('   Formats: ${formatsResponse.data}\n');

    // Test 3: Webhook Test
    print('3️⃣ Testing webhook...');
    final webhookResponse = await dio.post('/webhook/test');
    print('✅ Webhook test passed: ${webhookResponse.statusCode}');
    print('   Response: ${webhookResponse.data}\n');

    print('🎉 All tests passed! Flutter app should work correctly.');
    print('\n📱 You can now run the Flutter app with: flutter run');

  } on DioException catch (e) {
    print('❌ Connection failed:');
    if (e.response != null) {
      print('   Status: ${e.response?.statusCode}');
      print('   Error: ${e.response?.data}');
    } else {
      print('   Error: ${e.message}');
    }
    print('\n🔧 Troubleshooting:');
    print('   1. Make sure the PaddleOCR backend is running');
    print('   2. Check if port 8000 is accessible');
    print('   3. Run: python -m uvicorn app.main:app --host 0.0.0.0 --port 8000');
  } catch (e) {
    print('❌ Unexpected error: $e');
  }
}
