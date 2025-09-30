import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';

class VoiceServiceImpl {
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _audioStream;
  List<dynamic> _audioChunks = [];

  Future<bool> startRecording() async {
    try {
      print('🌐 Starting web audio capture...');
      _audioChunks.clear();
      
      // Get microphone access
      _audioStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'sampleRate': 16000
        }
      });
      
      if (_audioStream == null) {
        throw Exception('Failed to get microphone access');
      }
      
      // Create MediaRecorder with specific options for better Whisper compatibility
      var options = <String, dynamic>{};
      
      // Try different MIME types in order of preference for Whisper
      final mimeTypes = [
        'audio/webm;codecs=opus',     // WebM with Opus codec (widely supported)
        'audio/webm',                 // WebM default
        'audio/ogg;codecs=opus',      // OGG with Opus
        'audio/mp4',                  // MP4 audio
      ];
      
      String? selectedMimeType;
      for (final mimeType in mimeTypes) {
        if (html.MediaRecorder.isTypeSupported(mimeType)) {
          selectedMimeType = mimeType;
          print('✅ Using MIME type: $mimeType');
          break;
        }
      }
      
      if (selectedMimeType != null) {
        options['mimeType'] = selectedMimeType;
      }
      
      _mediaRecorder = html.MediaRecorder(_audioStream!, options);
      
      // Handle data available
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final data = (event as html.BlobEvent).data;
        if (data != null && data.size > 0) {
          _audioChunks.add(data);
          print('🎤 Audio chunk captured: ${data.size} bytes, type: ${data.type}');
        }
      });
      
      // Start recording with more frequent data collection for better quality
      _mediaRecorder!.start(500); // Collect data every 500ms
      print('✅ Web REAL recording started - microphone active');
      return true;
      
    } catch (e) {
      print('❌ Web microphone error: $e');
      return false;
    }
  }

  Future<bool> stopRecording() async {
    try {
      if (_mediaRecorder != null) {
        _mediaRecorder!.stop();
        
        // Stop audio stream
        if (_audioStream != null) {
          _audioStream!.getTracks().forEach((track) {
            track.stop();
          });
        }
        
        print('✅ Web recording stopped. Audio chunks: ${_audioChunks.length}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error stopping web recording: $e');
      return false;
    }
  }

  Future<Map<String, String>?> getAudioData() async {
    try {
      print('🌐 Processing web audio for Whisper backend...');
      
      if (_audioChunks.isEmpty) {
        print('❌ No audio data captured');
        return null;
      }
      
      // Create a single blob from all chunks
      final audioBlob = html.Blob(_audioChunks);
      print('📦 Audio blob size: ${audioBlob.size} bytes');
      
      // For Whisper API, we need to ensure we have proper audio data
      if (audioBlob.size == 0) {
        print('❌ Audio blob is empty');
        return null;
      }
      
      // Convert to base64
      final reader = html.FileReader();
      final completer = Completer<String>();
      
      reader.onLoad.listen((event) {
        final result = reader.result as String;
        final base64Data = result.split(',')[1]; // Remove data:audio/webm;base64, prefix
        print('✅ Audio converted to base64: ${base64Data.length} characters');
        completer.complete(base64Data);
      });
      
      reader.onError.listen((event) {
        print('❌ Failed to read audio data');
        completer.completeError('Failed to read audio data');
      });
      
      reader.readAsDataUrl(audioBlob);
      final audioData = await completer.future;
      
      // Validate that we have actual audio data
      if (audioData.isEmpty) {
        print('❌ Base64 audio data is empty');
        return null;
      }
      
      // Determine the actual content type from the blob
      String contentType = audioBlob.type.isNotEmpty ? audioBlob.type : 'audio/webm';
      String fileExtension = 'webm';
      
      print('✅ Web audio ready for Whisper:');
      print('   - Format: $contentType');
      print('   - Size: ${audioBlob.size} bytes');
      print('   - Base64 length: ${audioData.length} characters');
      
      // Set appropriate file extension based on content type
      if (contentType.contains('ogg')) {
        fileExtension = 'ogg';
      } else if (contentType.contains('mp4')) {
        fileExtension = 'mp4';
      } else if (contentType.contains('wav')) {
        fileExtension = 'wav';
      }
      
      return {
        'data': audioData,
        'contentType': contentType,
        'size': audioBlob.size.toString(),
        'filename': 'recording.$fileExtension',
      };
    } catch (e) {
      print('❌ Error getting web audio data: $e');
      return null;
    }
  }

  void clearAudio() {
    _audioChunks.clear();
  }

  /// Web doesn't support multiple formats, but add methods for compatibility
  bool tryNextFormat() {
    print('⚠️ Web only supports WebM format');
    return false;
  }

  void resetFormat() {
    print('⚠️ Web format reset not needed');
  }

  String getCurrentFormatInfo() {
    return 'audio/webm (WEBM)';
  }

  void dispose() {
    try {
      if (_audioStream != null) {
        _audioStream!.getTracks().forEach((track) => track.stop());
      }
      _mediaRecorder = null;
      _audioStream = null;
      _audioChunks.clear();
    } catch (e) {
      print('⚠️ Error during web voice service disposal: $e');
    }
  }
}