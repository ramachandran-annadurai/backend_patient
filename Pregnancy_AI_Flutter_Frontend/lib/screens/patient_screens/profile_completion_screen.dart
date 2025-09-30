import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile.dart';
import '../../utils/constants.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_checkbox.dart';
import '../../widgets/custom_date_picker.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _lastPeriodDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedBloodType = 'A+';
  bool _isPregnant = false;
  DateTime? _lastPeriodDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    _lastPeriodDateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Create ProfileModel from form data
    final profileModel = ProfileModel(
      userId: authProvider.patientId!,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      bloodType: _selectedBloodType,
      weight: _weightController.text.trim(),
      height: _heightController.text.trim(),
      isPregnant: _isPregnant,
      lastPeriodDate: _lastPeriodDate != null
          ? "${_lastPeriodDate!.year}-${_lastPeriodDate!.month.toString().padLeft(2, '0')}-${_lastPeriodDate!.day.toString().padLeft(2, '0')}"
          : null,
      pregnancyWeek: _calculatePregnancyWeek(),
      expectedDeliveryDate: _calculateExpectedDeliveryDate(),
      emergencyName: _emergencyNameController.text.trim(),
      emergencyRelationship: _emergencyRelationshipController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim(),
    );

    final success = await profileProvider.updateProfile(profileModel);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/account-created');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Failed to complete profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String? _calculatePregnancyWeek() {
    if (!_isPregnant || _lastPeriodDate == null) return null;

    final daysDiff = DateTime.now().difference(_lastPeriodDate!).inDays;
    int pregnancyWeek = (daysDiff / 7).floor();

    if (pregnancyWeek < 1) pregnancyWeek = 1;
    if (pregnancyWeek > 42) pregnancyWeek = 42;

    return pregnancyWeek.toString();
  }

  String? _calculateExpectedDeliveryDate() {
    if (!_isPregnant || _lastPeriodDate == null) return null;

    final expectedDelivery =
        _lastPeriodDate!.add(const Duration(days: 280)); // 40 weeks
    return "${expectedDelivery.year}-${expectedDelivery.month.toString().padLeft(2, '0')}-${expectedDelivery.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final profileProvider = context.read<ProfileProvider>();

    return AppScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // 🔑 fill full screen
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, isSmallScreen, profileProvider),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        _buildSectionTitle('Personal Details'),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomTextField(
                          controller: _weightController,
                          labelText: 'Weight (kg)',
                          hintText: 'Enter your weight',
                          prefixIcon: Icons.fitness_center,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Please enter your weight'
                              : null,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomTextField(
                          controller: _heightController,
                          labelText: 'Height (cm)',
                          hintText: 'Enter your height',
                          prefixIcon: Icons.height,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Please enter your height'
                              : null,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                        _buildSectionTitle('Pregnancy Information'),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomCheckbox(
                          value: _isPregnant,
                          onChanged: (v) {
                            setState(() {
                              _isPregnant = v;
                            });
                          },
                          label: 'Are you pregnant?',
                        ),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        if (_isPregnant)
                          CustomDatePicker(
                            selectedDate: _lastPeriodDate,
                            onDateSelected: (d) {
                              if (d != null) {
                                setState(() {
                                  _lastPeriodDate = d;
                                  _lastPeriodDateController.text =
                                      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                            hintText: 'Last Period Date',
                            icon: Icons.calendar_today,
                          ),
                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                        _buildSectionTitle('Emergency Contact'),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomTextField(
                          controller: _emergencyNameController,
                          labelText: 'Emergency Contact Name',
                          hintText: 'Enter emergency contact name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Please enter emergency contact name'
                              : null,
                        ),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomTextField(
                          controller: _emergencyRelationshipController,
                          labelText: 'Relationship',
                          hintText: 'Enter relationship',
                          prefixIcon: Icons.group,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Please enter relationship'
                              : null,
                        ),
                        SizedBox(height: isSmallScreen ? 16.0 : 20.0),

                        CustomTextField(
                          controller: _emergencyPhoneController,
                          labelText: 'Emergency Contact Phone',
                          hintText: 'Enter emergency contact phone',
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) => value?.trim().isEmpty == true
                              ? 'Please enter emergency contact phone'
                              : null,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                        Spacer(), // 🔑 pushes button to bottom

                        GradientButton(
                          text: 'Continue',
                          onPressed: profileProvider.isLoading
                              ? null
                              : _completeProfile,
                          startColor: AppTheme.brightBlue,
                          endColor: AppTheme.brightPink,
                        ),

                        SizedBox(height: isSmallScreen ? 24.0 : 32.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen,
      ProfileProvider profileProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed:
              profileProvider.isLoading ? null : () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            size: isSmallScreen ? 20.0 : 24.0,
            color: Colors.black87,
          ),
        ),
        Text(
          'Complete Profile',
          style: TextStyle(
            fontSize: isSmallScreen ? 18.0 : 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 48), // Balance the row
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.darkGray,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
