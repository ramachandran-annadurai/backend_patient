import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_profile_response.dart';
import '../../providers/auth_provider.dart';
import '../../providers/save_medication_log_provider.dart';
import '../../providers/get_upcoming_dosages_provider.dart';
import '../../services/patient_service/get_profile_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';

// Medication dosage model
class MedicationDosage {
  final String dosage;
  final String time;
  final String frequency;
  final bool reminderEnabled;
  final String? nextDoseTime;
  final String? specialInstructions;

  MedicationDosage({
    required this.dosage,
    required this.time,
    required this.frequency,
    this.reminderEnabled = false,
    this.nextDoseTime,
    this.specialInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'dosage': dosage,
      'time': time,
      'frequency': frequency,
      'reminder_enabled': reminderEnabled,
      'next_dose_time': nextDoseTime,
      'special_instructions': specialInstructions,
    };
  }
}

class PatientMedicationTrackingScreen extends StatefulWidget {
  final String date;

  const PatientMedicationTrackingScreen({
    super.key,
    required this.date,
  });

  @override
  State<PatientMedicationTrackingScreen> createState() =>
      _PatientMedicationTrackingScreenState();
}

class _PatientMedicationTrackingScreenState
    extends State<PatientMedicationTrackingScreen> {
  // Controllers for modern UI
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prescribedByController = TextEditingController();
  final TextEditingController _sideEffectController = TextEditingController();

  int? _currentPregnancyWeek;

  String _selectedMedicationType = 'prescription';

  // Multiple dosages support
  List<MedicationDosage> _dosages = [];

  @override
  void initState() {
    super.initState();
    _loadPatientPregnancyWeek();
    _setCurrentTime();
    _loadUpcomingDosages();
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    _prescribedByController.dispose();
    _sideEffectController.dispose();
    super.dispose();
  }

  // Load patient's pregnancy week when screen initializes
  Future<void> _loadPatientPregnancyWeek() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo['userId'] != null) {
        final PatientProfileResponse profileResponse =
            await GetProfileService().call(patientId: userInfo['userId']!);

        if (profileResponse.profile.isPregnant) {
          setState(() {
            _currentPregnancyWeek =
                int.tryParse(profileResponse.profile.pregnancyWeek.toString());
          });
          print('🔍 Loaded pregnancy week: $_currentPregnancyWeek');
        }
      }
    } catch (e) {
      print('⚠️ Could not load pregnancy week: $e');
    } finally {
      // Pregnancy week loading completed
    }
  }

  // Set current time for display
  void _setCurrentTime() {
    final now = DateTime.now();
    _timeController.text =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  // Load upcoming dosages using provider
  Future<void> _loadUpcomingDosages() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      if (userInfo['userId'] != null) {
        final upcomingProvider =
            Provider.of<GetUpcomingDosagesProvider>(context, listen: false);
        await upcomingProvider.loadUpcomingDosages(userInfo['userId']!);
      }
    } catch (e) {
      print('⚠️ Could not load upcoming dosages: $e');
    }
  }

  Future<void> _saveMedicationLog() async {
    if (_medicationNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter medication name'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_dosageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter dosage'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userInfo = await authProvider.getCurrentUserInfo();

      final pregnancyWeek = _currentPregnancyWeek ?? 20;

      // Create a single dosage entry for the simplified form
      final dosage = MedicationDosage(
        dosage: _dosageController.text.trim(),
        time: _timeController.text.trim(),
        frequency: 'Once', // Default frequency for quick log
        reminderEnabled: false,
        specialInstructions: _notesController.text.trim(),
      );

      // Save medication log with simplified data
      final medicationData = {
        'patient_id': userInfo['userId'] ?? 'unknown',
        'medication_name': _medicationNameController.text.trim(),
        'dosages': [dosage.toJson()],
        'date_taken': widget.date,
        'notes': _notesController.text.trim(),
        'prescribed_by': _prescribedByController.text.trim(),
        'medication_type': _selectedMedicationType,
        'pregnancy_week': pregnancyWeek,
      };

      print('🔍 ===== MEDICATION DATA DEBUG =====');
      print('🔍 Medication Name: ${medicationData['medication_name']}');
      print('🔍 Dosage: ${medicationData['dosages']}');
      print('🔍 ===== END DEBUG =====');

      // Use SaveMedicationLogProvider
      final saveProvider =
          Provider.of<SaveMedicationLogProvider>(context, listen: false);
      final success = await saveProvider.saveMedicationLog(medicationData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveProvider.successMessage ??
                'Medication logged successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                saveProvider.errorMessage ?? 'Failed to save medication log'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _clearForm() {
    _medicationNameController.clear();
    _dosageController.clear();
    _timeController.clear();
    _notesController.clear();
    _prescribedByController.clear();
    _sideEffectController.clear();
    setState(() {
      _selectedMedicationType = 'prescription';
      _dosages.clear();
    });
    _setCurrentTime(); // Reset time to current time
  }

  // Build modern header
  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: isSmallScreen ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            Text(
              'Medication Log',
              style: TextStyle(
                fontSize: isSmallScreen ? 18.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Today's medications.",
              style: TextStyle(
                fontSize: isSmallScreen ? 12.0 : 14.0,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.calendar_today,
            size: isSmallScreen ? 20.0 : 24.0,
            color: Colors.black87,
          ),
          onPressed: () {
            // TODO: Add date picker functionality
          },
        ),
      ],
    );
  }

  // Build upcoming doses card
  Widget _buildUpcomingDosesCard() {
    return Consumer<GetUpcomingDosagesProvider>(
      builder: (context, upcomingProvider, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.pink[600], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Doses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcomingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (upcomingProvider.upcomingDosages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: Text(
                      'No upcoming doses scheduled',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...upcomingProvider.upcomingDosages
                    .take(3)
                    .map((dosage) => _buildDoseItem(dosage)),
            ],
          ),
        );
      },
    );
  }

  // Build individual dose item
  Widget _buildDoseItem(Map<String, dynamic> dosage) {
    final time = dosage['next_dose_time'] ?? 'N/A';
    final medicationName = dosage['medication_name'] ?? 'Unknown';
    final dosageAmount = dosage['dosage'] ?? 'N/A';

    // Determine time period color
    final hour = int.tryParse(time.split(':')[0]) ?? 0;
    final isMorning = hour >= 6 && hour < 12;
    final backgroundColor = isMorning ? Colors.pink[50] : Colors.blue[50];
    final textColor = isMorning ? Colors.pink[600] : Colors.blue[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor!.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicationName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dosageAmount,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build log intake section
  Widget _buildLogIntakeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log Medication Intake',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manually enter your medication details or use other methods.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement scan prescription
                },
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: const Text('Scan Prescription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement search database
                },
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Search Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build modern input fields
  Widget _buildInputFields() {
    return Column(
      children: [
        // Medication Name
        TextField(
          controller: _medicationNameController,
          decoration: InputDecoration(
            labelText: 'Medication Name',
            hintText: 'e.g., Prenatal Vitamins',
            prefixIcon: const Icon(Icons.medication),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Dosage
        TextField(
          controller: _dosageController,
          decoration: InputDecoration(
            labelText: 'Dosage',
            hintText: 'e.g., 1 tablet',
            prefixIcon: const Icon(Icons.local_pharmacy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Time Taken
        TextField(
          controller: _timeController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Time Taken',
            prefixIcon: const Icon(Icons.access_time),
            suffixIcon: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _timeController.text =
                        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} ${picked.hour >= 12 ? 'PM' : 'AM'}';
                  });
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),

        // Notes
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Any side effects or comments...',
            prefixIcon: const Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header
                _buildHeader(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Upcoming Doses Card
                _buildUpcomingDosesCard(),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Log Medication Intake Section
                _buildLogIntakeSection(),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Modern Input Fields
                _buildInputFields(),
                SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                // Gradient Log Intake Button
                Consumer<SaveMedicationLogProvider>(
                  builder: (context, saveProvider, child) {
                    return GradientButton(
                      text: saveProvider.isSaving ? 'Logging...' : 'Log Intake',
                      onPressed:
                          saveProvider.isSaving ? null : _saveMedicationLog,
                      width: double.infinity,
                      height: 56,
                      startColor: AppTheme.brightBlue,
                      endColor: AppTheme.brightPink,
                    );
                  },
                ),

                // Bottom padding
                SizedBox(height: isSmallScreen ? 80.0 : 100.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
