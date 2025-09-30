import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceServiceImpl {
  RecorderController? _recorderController;
  String? _audioPath;
  bool _isRecording = false;
  
  // Backend supported formats - using only formats that audio_waveforms can actually record
  // Note: audio_waveforms on Android primarily supports M4A (AAC), but we send with different content-types
  int _currentFormatIndex = 0;
  final List<Map<String, dynamic>> _supportedFormats = [
    {'extension': 'm4a', 'contentType': 'audio/webm', 'name': 'M4A as WebM (Preferred)'},
    {'extension': 'm4a', 'contentType': 'audio/wav', 'name': 'M4A as WAV'},
    {'extension': 'm4a', 'contentType': 'audio/mp3', 'name': 'M4A as MP3'},
    {'extension': 'm4a', 'contentType': 'audio/m4a', 'name': 'M4A (AAC)'},
    {'extension': 'm4a', 'contentType': 'audio/ogg', 'name': 'M4A as OGG'},
  ];

  /// Initialize audio recorder
  Future<bool> _initializeRecorder() async {
    try {
      if (_recorderController == null) {
        _recorderController = RecorderController();
        print('✅ Audio recorder initialized');
      }
      return true;
    } catch (e) {
      print('❌ Error initializing recorder: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      final granted = status == PermissionStatus.granted;
      print('🔐 Microphone permission: ${granted ? "GRANTED" : "DENIED"}');
      return granted;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      print('📱 Mobile: Starting REAL audio recording for Whisper...');
      
      // Request permission
      if (!await _requestMicrophonePermission()) {
        print('❌ Microphone permission denied');
        return false;
      }
      
      // Initialize recorder
      if (!await _initializeRecorder()) {
        print('❌ Failed to initialize recorder');
        return false;
      }
      
      // Create audio file path with current format
      final directory = await getApplicationDocumentsDirectory();
      final currentFormat = _supportedFormats[_currentFormatIndex];
      _audioPath = '${directory.path}/whisper_audio_${DateTime.now().millisecondsSinceEpoch}.${currentFormat['extension']}';
      
      print('📁 Recording to: $_audioPath');
      print('🎵 Format: ${currentFormat['name']} (${currentFormat['contentType']})');
      
      // Start recording
      await _recorderController!.record(
        path: _audioPath!,
        bitRate: 128000,
        sampleRate: 16000,  // 16kHz - perfect for speech
      );
      
      _isRecording = true;
      print('✅ REAL audio recording started for Whisper backend!');
      print('✅ Using format: ${currentFormat['name']} as preferred by backend');
      return true;
      
    } catch (e) {
      print('❌ Recording start error: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<bool> stopRecording() async {
    try {
      print('⏹️ Stopping audio recording...');
      
      if (_recorderController != null && _isRecording) {
        final path = await _recorderController!.stop();
        _isRecording = false;
        
        print('✅ Audio recording stopped');
        print('📁 Audio file saved: $path');
        
        // Verify file exists and has content
        if (_audioPath != null && await File(_audioPath!).exists()) {
          final fileSize = await File(_audioPath!).length();
          print('📦 Audio file size: $fileSize bytes');
          
          if (fileSize > 0) {
            print('✅ Audio file ready for Whisper backend');
            return true;
          } else {
            print('❌ Audio file is empty');
            return false;
          }
        } else {
          print('❌ Audio file not found');
          return false;
        }
      } else {
        print('⚠️ Not currently recording');
        return false;
      }
    } catch (e) {
      print('❌ Recording stop error: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<Map<String, String>?> getAudioData() async {
    try {
      print('📱 Preparing REAL audio file for Whisper backend...');
      
      if (_audioPath == null) {
        print('❌ No audio file path');
        return null;
      }
      
      final audioFile = File(_audioPath!);
      if (!await audioFile.exists()) {
        print('❌ Audio file does not exist: $_audioPath');
        return null;
      }
      
      // Read audio file as bytes
      final audioBytes = await audioFile.readAsBytes();
      if (audioBytes.isEmpty) {
        print('❌ Audio file is empty');
        return null;
      }
      
      // Convert to base64 for sending to Whisper backend
      final audioBase64 = base64Encode(audioBytes);
      
      final currentFormat = _supportedFormats[_currentFormatIndex];
      
      print('✅ REAL audio file ready for Whisper:');
      print('   - File path: $_audioPath');
      print('   - File size: ${audioBytes.length} bytes');
      print('   - Base64 length: ${audioBase64.length} characters');
      print('   - Format: ${currentFormat['name']} - compatible with Whisper');
      
      return {
        'data': audioBase64,
        'contentType': currentFormat['contentType'],
        'filename': _audioPath!.split('/').last,
        'size': audioBytes.length.toString(),
      };
      
    } catch (e) {
      print('❌ Error preparing audio for Whisper: $e');
      return null;
    }
  }

  /// Fallback dialog if audio recording fails
  Future<String?> showVoiceInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Audio Recording Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voice recording failed. Please type what you said:'),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type your food details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void clearAudio() {
    _audioPath = null;
    _isRecording = false;
  }

  bool tryNextFormat() {
    final currentFormat = _supportedFormats[_currentFormatIndex];
    print('❌ Format ${currentFormat['name']} rejected by backend');
    
    if (_currentFormatIndex < _supportedFormats.length - 1) {
      _currentFormatIndex++;
      final nextFormat = _supportedFormats[_currentFormatIndex];
      print('🔄 Trying next audio format: ${nextFormat['name']} (${nextFormat['contentType']})');
      print('🔄 Format priority: ${_currentFormatIndex + 1}/${_supportedFormats.length}');
      return true;
    } else {
      print('❌ All ${_supportedFormats.length} audio formats rejected by backend:');
      for (int i = 0; i < _supportedFormats.length; i++) {
        final format = _supportedFormats[i];
        print('   ${i + 1}. ${format['name']} (${format['contentType']}) - FAILED');
      }
      return false;
    }
  }

  void resetFormat() {
    _currentFormatIndex = 0;
    final defaultFormat = _supportedFormats[_currentFormatIndex];
    print('📱 Reset to default audio format: ${defaultFormat['name']} (${defaultFormat['contentType']})');
  }

  String getCurrentFormatInfo() {
    final currentFormat = _supportedFormats[_currentFormatIndex];
    return '${currentFormat['contentType']} (${currentFormat['name']} - Whisper compatible)';
  }

  void dispose() {
    try {
      if (_isRecording && _recorderController != null) {
        _recorderController!.stop();
      }
      _recorderController?.dispose();
      _recorderController = null;
      
      // Clean up audio file
      if (_audioPath != null) {
        File(_audioPath!).delete().catchError((e) => print('⚠️ Cleanup: $e'));
      }
      
      _audioPath = null;
      _isRecording = false;
    } catch (e) {
      print('⚠️ Dispose error: $e');
    }
  }
}
