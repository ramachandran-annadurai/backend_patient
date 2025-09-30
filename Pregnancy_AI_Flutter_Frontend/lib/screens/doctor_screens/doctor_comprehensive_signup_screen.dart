import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/custom_text_field.dart';

class DoctorComprehensiveSignupScreen extends StatefulWidget {
  const DoctorComprehensiveSignupScreen({Key? key}) : super(key: key);

  @override
  State<DoctorComprehensiveSignupScreen> createState() => _DoctorComprehensiveSignupScreenState();
}

class _DoctorComprehensiveSignupScreenState extends State<DoctorComprehensiveSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  // Basic Information
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Personal Information
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Professional Information
  final _qualificationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _workingHospitalController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _experienceYearsController = TextEditingController();

  // Address Information
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _qualificationController.dispose();
    _specializationController.dispose();
    _workingHospitalController.dispose();
    _licenseNumberController.dispose();
    _experienceYearsController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Registration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Step ${_currentPage + 1} of $_totalPages'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      backgroundColor: AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildProfessionalInfoPage(),
                  _buildAddressInfoPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: _currentPage < _totalPages - 1
                        ? ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Next'),
                          )
                        : LoadingButton(
                            onPressed: _submitForm,
                            isLoading: isLoading,
                            text: 'Create Account',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          CustomTextField(
            controller: _usernameController,
            labelText: 'Username',
            hintText: 'Enter username',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Username is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'Enter email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _mobileController,
            labelText: 'Mobile Number',
            hintText: 'Enter mobile number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Mobile number is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter password',
            prefixIcon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Password is required';
              if (value!.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Professional Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          CustomTextField(
            controller: _firstNameController,
            labelText: 'First Name',
            hintText: 'Enter first name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'First name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _lastNameController,
            labelText: 'Last Name',
            hintText: 'Enter last name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Last name is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _qualificationController,
            labelText: 'Qualification (e.g., MBBS, MD)',
            hintText: 'Enter qualification',
            prefixIcon: Icons.school,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Qualification is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _specializationController,
            labelText: 'Specialization',
            hintText: 'Enter specialization',
            prefixIcon: Icons.medical_services,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Specialization is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _workingHospitalController,
            labelText: 'Working Hospital',
            hintText: 'Enter working hospital',
            prefixIcon: Icons.local_hospital,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Working hospital is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _licenseNumberController,
            labelText: 'License Number',
            hintText: 'Enter license number',
            prefixIcon: Icons.badge,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'License number is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _experienceYearsController,
            labelText: 'Years of Experience',
            hintText: 'Enter years of experience',
            prefixIcon: Icons.work,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Years of experience is required';
              if (int.tryParse(value!) == null) return 'Please enter a valid number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Phone number is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter address',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Address is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _cityController,
            labelText: 'City',
            hintText: 'Enter city',
            prefixIcon: Icons.location_city,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'City is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _stateController,
            labelText: 'State',
            hintText: 'Enter state',
            prefixIcon: Icons.map,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'State is required';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _zipCodeController,
            labelText: 'ZIP Code',
            hintText: 'Enter ZIP code',
            prefixIcon: Icons.pin_drop,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'ZIP code is required';
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.signup(
        username: _usernameController.text,
        email: _emailController.text,
        mobile: _mobileController.text,
        password: _passwordController.text,
        role: 'doctor',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        qualification: _qualificationController.text,
        specialization: _specializationController.text,
        workingHospital: _workingHospitalController.text,
        licenseNumber: _licenseNumberController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        experienceYears: _experienceYearsController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor account created successfully! Please verify your email.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pushReplacementNamed(context, '/otp-verification', arguments: {
          'email': _emailController.text,
          'role': 'doctor',
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Signup failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
