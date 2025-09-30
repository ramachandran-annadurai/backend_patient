import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/patient_profile_response.dart';
import '../repositories/profile_repository.dart';
import '../models/profile.dart';
import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  // State properties
  bool _isLoading = false;
  PatientProfileResponse? _profile;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  PatientProfileResponse? get profile => _profile;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  String get displayName => _profile?.profile.firstName ?? 'Unknown';

  // Load profile from context (gets user ID from AuthProvider)
  Future<void> loadProfileFromContext(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();
      final String? patientId = userInfo['userId'];

      if (patientId != null && patientId.isNotEmpty) {
        await loadProfile(patientId);
      }
    } catch (e) {
      _setError('Failed to load user information: $e');
    }
  }

  // Load profile for a specific patient
  Future<void> loadProfile(String patientId) async {
    try {
      _setLoading(true);
      _clearError();

      final PatientProfileResponse profileModel =
          await _repository.getProfile(patientId: patientId);

      _profile = profileModel;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Refresh current profile
  Future<void> refreshProfile() async {
    if (_profile?.profile.patientId != null) {
      await loadProfile(_profile!.profile.patientId);
    }
  }

  // Update profile
  Future<bool> updateProfile(ProfileModel updatedProfile) async {
    try {
      _setLoading(true);
      _clearError();

      // Update profile using repository

      final response = await _repository.completeProfile(
        patientId: updatedProfile.userId,
        firstName: updatedProfile.firstName ?? '',
        lastName: updatedProfile.lastName ?? '',
        dateOfBirth: updatedProfile.dateOfBirth ?? '',
        bloodType: updatedProfile.bloodType ?? '',
        weight: updatedProfile.weight ?? '',
        height: updatedProfile.height ?? '',
        isPregnant: updatedProfile.isPregnant ?? false,
        lastPeriodDate: updatedProfile.lastPeriodDate,
        pregnancyWeek: updatedProfile.pregnancyWeek,
        expectedDeliveryDate: updatedProfile.expectedDeliveryDate,
        emergencyName: updatedProfile.emergencyName ?? '',
        emergencyRelationship: updatedProfile.emergencyRelationship ?? '',
        emergencyPhone: updatedProfile.emergencyPhone ?? '',
      );

      // Success response with typed model
      print('✅ Profile completion successful: ${response.message}');
      print('🆔 Patient ID: ${response.patientId}');
      print('📊 Profile Complete: ${response.isProfileComplete}');

      // Update local profile with new data
      // Note: We would need to create a new PatientProfileResponse from the updated ProfileModel
      // For now, we'll just mark as successful and let the UI refresh
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Clear profile data
  void clearProfile() {
    _profile = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
