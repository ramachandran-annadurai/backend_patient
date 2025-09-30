import 'package:flutter/foundation.dart';
import '../repositories/medication_repository.dart';
import '../services/core/api_core.dart';
import '../models/save_medication_log_request.dart';
import '../models/save_medication_log_response.dart';

class SaveMedicationLogProvider extends ChangeNotifier {
  final MedicationRepository _medicationRepository = MedicationRepository();
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> saveMedicationLog(Map<String, dynamic> medicationData) async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = SaveMedicationLogRequest.fromJson(medicationData);
      final SaveMedicationLogResponseModel response =
          await _medicationRepository.saveMedicationLog(request);

      if (response.success) {
        _successMessage = response.message.isNotEmpty
            ? response.message
            : 'Medication logged successfully!';
        return true;
      }
      _errorMessage = response.message.isNotEmpty
          ? response.message
          : 'Failed to save medication log';
      return false;
    } on ErrorResponse catch (e) {
      _errorMessage = e.error;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _isSaving = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
