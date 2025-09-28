import 'dart:io';
import 'package:dio/dio.dart';
import '../models/ocr_response.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 300), // 5 minutes for large images
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));
  }

  /// Upload a file for OCR processing
  Future<FileUploadResult> uploadFileForOCR(File file) async {
    try {
      String fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      Response response = await _dio.post(
        '/ocr/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        OCRResponse ocrResponse = OCRResponse.fromJson(response.data);
        return FileUploadResult.success(ocrResponse, fileName);
      } else {
        return FileUploadResult.error('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      
      if (e.response != null) {
        // Server responded with error status
        errorMessage = e.response?.data?['detail'] ?? 'Server error occurred';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. The server is taking too long to respond.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check if the server is running.';
      }
      
      return FileUploadResult.error(errorMessage);
    } catch (e) {
      return FileUploadResult.error('Unexpected error: $e');
    }
  }

  /// Process base64 encoded image
  Future<FileUploadResult> processBase64Image(String base64Image) async {
    try {
      Response response = await _dio.post(
        '/ocr/base64',
        data: {
          'image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        OCRResponse ocrResponse = OCRResponse.fromJson(response.data);
        return FileUploadResult.success(ocrResponse, 'base64_image');
      } else {
        return FileUploadResult.error('Base64 processing failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      
      if (e.response != null) {
        errorMessage = e.response?.data?['detail'] ?? 'Server error occurred';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. The server is taking too long to respond.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check if the server is running.';
      }
      
      return FileUploadResult.error(errorMessage);
    } catch (e) {
      return FileUploadResult.error('Unexpected error: $e');
    }
  }

  /// Upload file bytes for OCR processing (web-compatible)
  Future<bool> testConnection() async {
    try {
      Response response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  Future<FileUploadResult> uploadFileBytesForOCR(List<int> fileBytes, String fileName) async {
    try {
      // Determine MIME type based on file extension
      String contentType = _getContentTypeFromFileName(fileName);
      
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType.parse(contentType),
        ),
      });

      Response response = await _dio.post(
        '/ocr/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        OCRResponse ocrResponse = OCRResponse.fromJson(response.data);
        if (ocrResponse.success) {
          return FileUploadResult.success(ocrResponse, fileName);
        } else {
          return FileUploadResult.error(ocrResponse.error ?? 'OCR processing failed');
        }
      } else {
        return FileUploadResult.error('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';
      if (e.response != null) {
        errorMessage = e.response?.data?['detail'] ?? 'Server error occurred';
        if (e.response?.data is Map && e.response?.data['detail'] is String) {
          errorMessage = e.response?.data['detail'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Request timeout. The server is taking too long to respond.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check if the server is running.';
      }
      
      return FileUploadResult.error(errorMessage);
    } catch (e) {
      return FileUploadResult.error('Unexpected error: $e');
    }
  }

  /// Get supported file formats
  Future<Map<String, dynamic>> getSupportedFormats() async {
    try {
      Response response = await _dio.get('/ocr/enhanced/formats');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get supported formats');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      Response response = await _dio.get('/health');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Health check failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Test webhook
  Future<Map<String, dynamic>> testWebhook() async {
    try {
      Response response = await _dio.post('/webhook/test');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Webhook test failed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Helper method to determine content type from filename
  String _getContentTypeFromFileName(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
