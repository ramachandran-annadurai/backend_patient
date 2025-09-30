import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/constants.dart';
import '../config/n8n_config.dart';

// Conditional imports for web-specific functionality
import 'enhanced_voice_service_web.dart' if (dart.library.io) 'enhanced_voice_service_mobile.dart' as voice_impl;

class EnhancedVoiceService {
  bool _isRecording = false;
  String _googleApiKey = '';

  // Platform-specific implementation
  late final voice_impl.VoiceServiceImpl _impl;
  
  EnhancedVoiceService() {
    _impl = voice_impl.VoiceServiceImpl();
  }

  /// Initialize the voice service and check if recording is available
  Future<bool> initialize() async {
    try {
      print('🔧 Initializing voice service...');
      
    if (!kIsWeb) {
        // Check permissions first
        final hasPermission = await _requestPermissions();
        if (!hasPermission) {
          print('❌ Voice service initialization failed - no microphone permission');
        return false;
      }
      }
      
      print('✅ Voice service initialized successfully');
      return true;
    } catch (e) {
      print('❌ Voice service initialization failed: $e');
      return false;
    }
  }

  bool get isSupported {
    // Supported on both web and mobile platforms
    return true;
  }

  /// Request microphone permissions for mobile
  Future<bool> _requestPermissions() async {
    if (kIsWeb) return true; // Web handles permissions automatically
    
    try {
      print('🔐 Requesting microphone permission...');
      final status = await Permission.microphone.request();
      final granted = status == PermissionStatus.granted;
      print('🔐 Microphone permission: ${granted ? "✅ GRANTED" : "❌ DENIED"}');
      return granted;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      print('🎤 Starting REAL voice recording...');
      _isRecording = true;
      
      if (!kIsWeb) {
        // Mobile implementation - request permissions first
        final hasPermission = await _requestPermissions();
        if (!hasPermission) {
          print('❌ Microphone permission denied');
          _isRecording = false;
          return false;
        }
      }
      
      final success = await _impl.startRecording();
      if (!success) {
        _isRecording = false;
      }
      
      return success;
    } catch (e) {
      print('❌ Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<bool> stopRecording() async {
    try {
      if (!_isRecording) {
        print('⚠️ No active recording to stop');
        return false;
      }
      
      print('⏹️ Stopping recording...');
      _isRecording = false;
      
      final success = await _impl.stopRecording();
      return success;
    } catch (e) {
      print('❌ Error stopping recording: $e');
      return false;
    }
  }

  bool get isRecording => _isRecording;

  /// Send audio to backend for transcription
  Future<String?> transcribeAudio({BuildContext? context, bool useN8NForSymptoms = false, bool useN8NForFood = false}) async { 
    try {
      print('🎤 Transcribing audio with backend...');
      print('📱 Platform: ${kIsWeb ? "Web" : "Mobile"}');
      
      // Get audio/speech data from platform implementation
      print('📤 Getting audio/speech data from platform implementation...');
      final audioData = await _impl.getAudioData();
      
      if (audioData == null) {
        print('❌ Failed to get audio/speech data from platform implementation');
        
        // For mobile, show dialog as fallback
        if (!kIsWeb && context != null) {
          print('📱 Mobile: Showing fallback voice input dialog...');
          final spokenText = await (_impl as dynamic).showVoiceInputDialog(context);
          
          if (spokenText != null && spokenText.isNotEmpty) {
            print('✅ Mobile: Fallback input received: $spokenText');
            // Apply translation and return
            final translated = await translateTamilToEnglish(spokenText);
            return translated ?? spokenText;
          }
        }
        
        return 'Error: No audio data captured. Please check microphone permissions.';
      }
      
      print('✅ Audio/Speech data retrieved:');
      print('   - Content Type: ${audioData['contentType']}');
      print('   - Data Length: ${audioData['data']?.length ?? 0} characters');
      print('   - Data Preview: ${audioData['data']?.substring(0, 50) ?? "null"}...');
      
      // Check if this is real audio data for Whisper backend
      if (audioData['contentType']?.startsWith('audio/') == true) {
        print('🎤 Real audio detected - sending to Whisper backend...');
        print('   - Format: ${audioData['contentType']}');
        print('   - Size: ${audioData['size'] ?? 'unknown'} bytes');
        print('   - Filename: ${audioData['filename'] ?? 'audio.m4a'}');
      }
      
      // Determine which URL to use based on the context
      String url;
      Map<String, dynamic> requestBody;
      
      if (useN8NForSymptoms) {
        // Use N8N webhook for symptoms
        url = N8NConfig.symptomsWebhookUrl;
        print('🔗 Sending symptoms audio to N8N webhook: $url');
        
        // N8N webhook format for symptoms
        requestBody = {
          'audio_data': audioData['data'],  // Base64 encoded audio data
          'content_type': audioData['contentType'],
          'platform': kIsWeb ? 'web' : 'mobile',
          'type': 'symptoms',
          'language': 'en',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (useN8NForFood) {
        // Use N8N webhook for food
        url = N8NConfig.foodWebhookUrl;
        print('🔗 Sending food audio to N8N webhook: $url');
        
        // N8N webhook format for food
        requestBody = {
          'audio_data': audioData['data'],  // Base64 encoded audio data
          'content_type': audioData['contentType'],
          'platform': kIsWeb ? 'web' : 'mobile',
          'type': 'food',
          'language': 'en',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        // Use the regular transcription endpoint (legacy fallback)
        url = '${ApiConfig.nutritionBaseUrl}${ApiConfig.transcribeEndpoint}';
        print('🌐 Sending audio to regular backend: $url');
        
        // Use the EXACT format that works in doctor folder (simple_voice_service.dart)
        requestBody = {
          'audio': audioData['data'],  // Base64 encoded audio data
          'language': 'en',           // Language for transcription
          'method': 'whisper',        // Explicitly request OpenAI Whisper
        };
      }
      
      print('📤 Request body prepared (${jsonEncode(requestBody).length} bytes)');
      print('📤 Using ${useN8NForSymptoms ? "N8N symptoms webhook" : useN8NForFood ? "N8N food webhook" : "Whisper API"} format');
      
      http.Response response;
      
      try {
        // Use the exact same format that works in the doctor folder
        print('📤 Sending with Whisper format...');
        response = await http.post(
          Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
          body: jsonEncode(requestBody),
        ).timeout(Duration(seconds: 60)); // Same timeout as doctor folder
        
        print('📡 Whisper API response: ${response.statusCode}');
      
    } catch (e) {
        print('❌ Request failed: $e');
        rethrow;
      }
      
      print('📡 Final backend response: ${response.statusCode}');
      print('📡 Response headers: ${response.headers}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Backend response data: $responseData');
        
        if (useN8NForSymptoms || useN8NForFood) {
          // Handle N8N webhook response for symptoms or food
          String webhookType = useN8NForSymptoms ? 'symptoms' : 'food';
          print('✅ N8N webhook response received for $webhookType');
          print('🔍 Full N8N response: $responseData');
          
          // Try to extract meaningful response from N8N webhook
          String result = '';
          
          // Check for common N8N response fields
          if (responseData['success'] == true || responseData['status'] == 'success') {
            // Successful processing
            result = responseData['message'] ?? 
                    responseData['result'] ?? 
                    responseData['transcription'] ?? 
                    responseData['analysis'] ?? 
                    responseData['output'] ?? 
                    '$webhookType processed successfully by N8N workflow';
          } else if (responseData['error'] != null) {
            // Error response
            result = 'N8N Error: ${responseData['error']}';
          } else if (responseData['message'] != null) {
            // General message
            result = responseData['message'].toString();
          } else {
            // Fallback - show the full response as JSON
            result = 'N8N Response: ${jsonEncode(responseData)}';
          }
          
          print('✅ N8N $webhookType result: $result');
          return result;
        } else {
          // Handle regular Whisper API response for food
          if (responseData['success'] == true) {
            final transcription = responseData['transcription'] as String?;
            
            if (transcription != null && transcription.isNotEmpty) {
              print('✅ Whisper transcription successful: $transcription');
              
              // Apply Tamil to English translation if needed
              final translated = await translateTamilToEnglish(transcription);
              return translated ?? transcription;
            } else {
              print('⚠️ Empty transcription from Whisper API');
              print('⚠️ Full response: $responseData');
              return 'Error: Whisper API returned empty transcription. Please try again.';
            }
          } else {
            print('❌ Whisper API returned success=false');
            print('❌ Error message: ${responseData['message'] ?? 'Unknown error'}');
            return 'Error: ${responseData['message'] ?? 'Transcription failed'}';
          }
        }
      } else {
        print('❌ Backend error: ${response.statusCode}');
        print('❌ Error body: ${response.body}');
        
                // Handle N8N webhook errors differently
        if (useN8NForSymptoms || useN8NForFood) {
          String webhookType = useN8NForSymptoms ? 'symptoms' : 'food';
          try {
            final errorData = jsonDecode(response.body);
            final errorMessage = errorData['error'] ?? 
                                errorData['message'] ?? 
                                'N8N $webhookType webhook error (${response.statusCode})';
            return 'N8N Error: $errorMessage';
          } catch (e) {
            return 'N8N Error: HTTP ${response.statusCode} - ${response.body}';
          }
        }
        
        // Handle specific error codes with format retry logic for regular API
        switch (response.statusCode) {
          case 400:
            // Try next audio format if available (mobile only)
            if (!kIsWeb && (response.body.contains('audio') || response.body.contains('format') || response.body.contains('invalid'))) {
              // Only mobile has multiple format support
              try {
                final currentFormatInfo = (_impl as dynamic).getCurrentFormatInfo();
                print('❌ Backend rejected format: $currentFormatInfo');
                print('📝 Backend error: ${response.body}');
                
                final hasNextFormat = (_impl as dynamic).tryNextFormat();
                if (hasNextFormat) {
                  final nextFormatInfo = (_impl as dynamic).getCurrentFormatInfo();
                  print('🔄 Retrying with next format: $nextFormatInfo');
                  // Retry with next format
                  return await transcribeAudio(); // Recursive call with next format
        } else {
                  return 'Error: All audio formats (WebM, WAV, MP3, M4A, OGG) rejected by backend. Please check backend logs.';
                }
    } catch (e) {
                print('⚠️ Format retry error: $e');
              }
            }
            return 'Error: Invalid audio format. Backend supports: WebM, WAV, MP3, M4A, OGG.';
          case 401:
            return 'Error: Authentication failed. Please check your login.';
          case 403:
            return 'Error: Access denied. Please check your permissions.';
          case 404:
            return 'Error: Transcription service not found. Please contact support.';
          case 500:
            return 'Error: Server processing failed. The audio format may not be supported.';
          case 503:
            return 'Backend temporarily unavailable. Please type what you said or try again later.';
          case 429:
            return 'Error: Too many requests. Please wait and try again.';
          default:
            return 'Error: Backend responded with ${response.statusCode}. Please check network connection.';
        }
      }
      
    } catch (e, stackTrace) {
      print('❌ Error transcribing audio: $e');
      print('❌ Stack trace: $stackTrace');
      
      if (e.toString().contains('TimeoutException')) {
        return 'Error: Network timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException')) {
        return 'Error: Network connection failed. Please check your internet connection.';
            } else {
        return 'Error: Transcription failed - $e';
      }
    }
  }

  void clearAudio() {
    _isRecording = false;
    _impl.clearAudio();
    print('🧹 Audio data cleared');
  }

  String getRecordingInfo() {
    if (kIsWeb) {
      return 'Web voice recording - using MediaRecorder API with backend transcription';
    } else {
      return 'Mobile voice recording - using audio_waveforms with backend transcription';
    }
  }

  Future<String?> testAudioRecording() async {
    try {
      print('🧪 Testing audio recording functionality...');
      
      final startSuccess = await startRecording();
      if (!startSuccess) {
        return '❌ Failed to start recording - check microphone permission';
      }
      
      print('🧪 Recording for 3 seconds...');
      await Future.delayed(Duration(seconds: 3));
      
      final stopSuccess = await stopRecording();
      if (!stopSuccess) {
        return '❌ Failed to stop recording';
      }
      
      // Check if audio was actually captured
      final audioData = await _impl.getAudioData();
      if (audioData == null) {
        return '❌ No audio data captured - recording failed';
      }
      
      if (kIsWeb) {
        return '✅ Audio recording test successful (web platform) - ${audioData['data']?.length ?? 0} chars captured';
      } else {
        return '✅ Audio recording test successful (mobile platform) - ${audioData['data']?.length ?? 0} chars captured';
      }
    } catch (e) {
      return '❌ Audio recording test failed: $e';
    }
  }

  String getConnectionInfo() {
    return 'Backend URL: ${ApiConfig.nutritionBaseUrl}\n'
           'Transcribe Endpoint: ${ApiConfig.transcribeEndpoint}\n'
           'Full URL: ${ApiConfig.nutritionBaseUrl}${ApiConfig.transcribeEndpoint}';
  }

  /// Test backend connectivity
  Future<String> testBackendConnection() async {
    try {
      print('🌐 Testing backend connection...');
      final url = '${ApiConfig.nutritionBaseUrl}${ApiConfig.transcribeEndpoint}';
      print('🔗 Testing URL: $url');
      
      // Try a simple GET request first to test connectivity
      final testResponse = await http.get(
        Uri.parse(ApiConfig.nutritionBaseUrl),
      ).timeout(Duration(seconds: 10));
      
      print('✅ Backend connectivity test: ${testResponse.statusCode}');
      
      if (testResponse.statusCode == 200 || testResponse.statusCode == 404) {
        return '✅ Backend is reachable at ${ApiConfig.nutritionBaseUrl}';
      } else {
        return '⚠️ Backend responded with status ${testResponse.statusCode}';
      }
    } catch (e) {
      print('❌ Backend connectivity test failed: $e');
      
      if (e.toString().contains('TimeoutException')) {
        return '❌ Backend connection timeout - check internet connection';
      } else if (e.toString().contains('SocketException')) {
        return '❌ Network connection failed - check internet connection';
      } else {
        return '❌ Backend connection failed: $e';
      }
    }
  }

  void setGoogleApiKey(String apiKey) {
    _googleApiKey = apiKey;
    print('🔑 Google API key configured: ${apiKey.isNotEmpty ? 'Set' : 'Not set'}');
  }

  bool get hasGoogleApiKey => _googleApiKey.isNotEmpty;

  // Translation methods for Tamil to English
  Future<String?> translateTamilToEnglish(String tamilText) async {
    try {
      print('🔤 Translation request: $tamilText');
      
      // Simple word mapping for common Tamil food terms
      final tamilEnglishDict = {
        'சாதம்': 'rice',
        'ரொட்டி': 'bread',
        'தோசை': 'dosa',
        'இட்லி': 'idli',
        'காய்கறிகள்': 'vegetables',
        'மீன்': 'fish',
        'முட்டை': 'egg',
        'பருப்பு': 'dal',
        'தயிர்': 'curd',
        'நான்': 'I',
        'சாப்பிட்டேன்': 'ate',
        'சாப்பிடுகிறேன்': 'eating',
        'இன்று': 'today',
        'மற்றும்': 'and',
      };
      
      String result = tamilText;
      
      // Simple word replacement
      tamilEnglishDict.forEach((tamil, english) {
        result = result.replaceAll(tamil, english);
      });
      
      if (result != tamilText) {
        print('✅ Translation successful: $result');
        return result;
      }
      
      return tamilText; // Return original if no translation found
    } catch (e) {
      print('❌ Translation error: $e');
      return tamilText;
    }
  }
  
  /// Clean up resources
  void dispose() {
    try {
      _impl.dispose();
      print('🧹 Enhanced voice service disposed');
    } catch (e) {
      print('⚠️ Error during disposal: $e');
    }
  }
}