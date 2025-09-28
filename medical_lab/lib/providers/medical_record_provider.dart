import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import '../models/ocr_response.dart';
import '../services/api_service.dart';
import 'dart:io';

class MedicalRecordProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  MedicalRecord _medicalRecord = MedicalRecord();
  bool _isLoading = false;
  String? _error;
  Map<String, String> _uploadedFiles = {};

  // Getters
  MedicalRecord get medicalRecord => _medicalRecord;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, String> get uploadedFiles => _uploadedFiles;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all errors and reset loading state
  void clearAllErrors() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Test backend connection
  Future<bool> testBackendConnection() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool isConnected = await _apiService.testConnection();
      
      if (isConnected) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Backend server is not responding";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Connection test failed: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update medical record fields
  void updateMedicalConditions(String value) {
    _medicalRecord = _medicalRecord.copyWith(medicalConditions: value);
    notifyListeners();
  }

  void updateAllergies(String value) {
    _medicalRecord = _medicalRecord.copyWith(allergies: value);
    notifyListeners();
  }

  void updateCurrentMedications(String value) {
    _medicalRecord = _medicalRecord.copyWith(currentMedications: value);
    notifyListeners();
  }

  void updatePreviousPregnancies(String value) {
    _medicalRecord = _medicalRecord.copyWith(previousPregnancies: value);
    notifyListeners();
  }

  void updateFamilyHealthHistory(String value) {
    _medicalRecord = _medicalRecord.copyWith(familyHealthHistory: value);
    notifyListeners();
  }

  // Upload file and process with OCR
  Future<void> uploadFileForOCR(File file, String fieldName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FileUploadResult result = await _apiService.uploadFileForOCR(file);
      
      if (result.success && result.ocrResponse != null) {
        // Store the extracted text in the appropriate field
        String extractedText = result.ocrResponse!.extractedText;
        
        switch (fieldName) {
          case 'medicalConditions':
            updateMedicalConditions(extractedText);
            break;
          case 'allergies':
            updateAllergies(extractedText);
            break;
          case 'currentMedications':
            updateCurrentMedications(extractedText);
            break;
          case 'previousPregnancies':
            updatePreviousPregnancies(extractedText);
            break;
          case 'familyHealthHistory':
            updateFamilyHealthHistory(extractedText);
            break;
        }
        
        // Store the uploaded file info
        _uploadedFiles[fieldName] = result.fileName ?? 'Unknown file';
        
        _error = null;
      } else {
        _error = result.error ?? 'Failed to process file';
      }
    } catch (e) {
      _error = 'Error uploading file: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload file bytes for OCR (web-compatible)
  Future<void> uploadFileBytesForOCR(List<int> fileBytes, String fileName, String fieldName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      FileUploadResult result = await _apiService.uploadFileBytesForOCR(fileBytes, fileName);

      if (result.success && result.ocrResponse != null && result.ocrResponse!.extractedText != null) {
        String extractedText = result.ocrResponse!.extractedText!;
        
        // Update the appropriate field based on fieldName
        switch (fieldName) {
          case 'medicalConditions':
            updateMedicalConditions(extractedText);
            break;
          case 'allergies':
            updateAllergies(extractedText);
            break;
          case 'currentMedications':
            updateCurrentMedications(extractedText);
            break;
          case 'previousPregnancies':
            updatePreviousPregnancies(extractedText);
            break;
          case 'familyHealthHistory':
            updateFamilyHealthHistory(extractedText);
            break;
        }
        
        // Store the uploaded file info
        _uploadedFiles[fieldName] = fileName;
        
        _error = null;
      } else {
        _error = result.error ?? result.ocrResponse?.error ?? 'Failed to process file';
      }
    } catch (e) {
      _error = 'Error uploading file: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save medical record (placeholder for future implementation)
  Future<void> saveMedicalRecord() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Here you would typically save to a database or send to a server
      // For now, we'll just simulate a save operation
      await Future.delayed(const Duration(seconds: 1));
      
      _medicalRecord = _medicalRecord.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _error = null;
    } catch (e) {
      _error = 'Error saving medical record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data
  void clearAllData() {
    _medicalRecord = MedicalRecord();
    _uploadedFiles.clear();
    _error = null;
    notifyListeners();
  }

  // Get field value by name
  String? getFieldValue(String fieldName) {
    switch (fieldName) {
      case 'medicalConditions':
        return _medicalRecord.medicalConditions;
      case 'allergies':
        return _medicalRecord.allergies;
      case 'currentMedications':
        return _medicalRecord.currentMedications;
      case 'previousPregnancies':
        return _medicalRecord.previousPregnancies;
      case 'familyHealthHistory':
        return _medicalRecord.familyHealthHistory;
      default:
        return null;
    }
  }

  // Check if any field has data
  bool get hasData {
    return _medicalRecord.medicalConditions?.isNotEmpty == true ||
           _medicalRecord.allergies?.isNotEmpty == true ||
           _medicalRecord.currentMedications?.isNotEmpty == true ||
           _medicalRecord.previousPregnancies?.isNotEmpty == true ||
           _medicalRecord.familyHealthHistory?.isNotEmpty == true;
  }
}
