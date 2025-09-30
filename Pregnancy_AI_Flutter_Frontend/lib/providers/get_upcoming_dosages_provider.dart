import 'package:flutter/foundation.dart';
import '../repositories/medication_repository.dart';
import '../services/core/api_core.dart';
import '../models/get_upcoming_dosages_response.dart';

class GetUpcomingDosagesProvider extends ChangeNotifier {
  final MedicationRepository _medicationRepository = MedicationRepository();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _upcomingDosages = [];
  List<dynamic> _prescriptionMedications = [];
  int _totalUpcoming = 0;
  int _totalPrescriptions = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get upcomingDosages => _upcomingDosages;
  List<dynamic> get prescriptionMedications => _prescriptionMedications;
  int get totalUpcoming => _totalUpcoming;
  int get totalPrescriptions => _totalPrescriptions;

  Future<bool> loadUpcomingDosages(String patientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Real API call
      final GetUpcomingDosagesResponseModel response =
          await _medicationRepository.getUpcomingDosages(patientId);

      if (response.success) {
        _upcomingDosages = List<dynamic>.from(response.upcomingDosages);
        _prescriptionMedications =
            List<dynamic>.from(response.prescriptionMedications);
        _totalUpcoming = response.totalUpcoming;
        _totalPrescriptions = response.totalPrescriptions;
        return true;
      }
      _errorMessage = 'Failed to load upcoming dosages';
      return false;
    } on ErrorResponse catch (e) {
      _errorMessage = e.error;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _upcomingDosages = [];
    _prescriptionMedications = [];
    _totalUpcoming = 0;
    _totalPrescriptions = 0;
    notifyListeners();
  }
}
