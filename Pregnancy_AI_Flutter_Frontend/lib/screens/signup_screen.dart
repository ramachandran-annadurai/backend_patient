import 'package:flutter/material.dart';
import 'package:patient_alert_app/utils/constants.dart';
import 'package:patient_alert_app/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_factory.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';
import '../models/signup_model.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPregnant = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final authFactory =
        Provider.of<AuthProviderFactory>(context, listen: false);
    bool success = false;

    // Use appropriate auth provider based on role
    if (widget.role == 'patient') {
      final signupModel = SignupModel(
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
        userType: 'patient',
        isPregnant: _isPregnant,
      );
      success = await authFactory.patient.signup(signupModel);
    } else if (widget.role == 'doctor') {
      success = await authFactory.doctor.signup(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (success && mounted) {
      // Navigate to OTP verification
      Navigator.pushNamed(
        context,
        '/otp-verification',
        arguments: {
          'email': _emailController.text.trim(),
          'role': widget.role,
        },
      );
    } else if (mounted) {
      final cleanErrorMessage =
          _extractCleanErrorMessage(authFactory.error ?? 'Signup failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cleanErrorMessage),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  /// Extract clean error message from complex JSON error responses
  String _extractCleanErrorMessage(String errorMessage) {
    // Handle the specific nested structure: {detail: {message: "text"}}
    if (errorMessage.contains('detail:') && errorMessage.contains('message:')) {
      try {
        // Extract message using regex: find text after "message:" until next comma or closing brace
        final messageMatch =
            RegExp(r'message:\s*([^,}]+)').firstMatch(errorMessage);
        if (messageMatch != null) {
          String extracted = messageMatch.group(1)?.trim() ?? errorMessage;
          // Remove any trailing punctuation and clean up
          extracted = extracted.replaceAll(RegExp(r'[,}\.]+$'), '');
          return extracted;
        }
      } catch (e) {
        // Fallback: try simple string manipulation
        if (errorMessage.contains('message:')) {
          final parts = errorMessage.split('message:');
          if (parts.length > 1) {
            String message = parts[1].split(',')[0].trim();
            message = message.replaceAll(RegExp(r'^["\s]+|["\s,}]+$'), '');
            return message;
          }
        }
      }
    }

    return errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGray,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Signup Form
                  CustomTextField(
                    controller: _usernameController,
                    labelText: AppStrings.username,
                    hintText: 'Enter your username',
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // First Name field
                  CustomTextField(
                    controller: _firstNameController,
                    labelText: 'First Name',
                    hintText: 'Enter your first name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last Name field
                  CustomTextField(
                    controller: _lastNameController,
                    labelText: 'Last Name',
                    hintText: 'Enter your last name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'Enter your email address',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _mobileController,
                    labelText: AppStrings.mobile,
                    hintText: 'Enter your mobile number',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: AppStrings.confirmPassword,
                    hintText: 'Confirm your password',
                    prefixIcon: Icons.lock,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Pregnancy Toggle (only for patients)
                  if (widget.role == 'patient')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.lightGray),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pregnant_woman, color: AppTheme.textGray),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Are you currently pregnant?',
                              style: TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isPregnant,
                            onChanged: (value) =>
                                setState(() => _isPregnant = value),
                            activeColor: AppTheme.brightBlue,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                  // Create Account button
                  Consumer<AuthProviderFactory>(
                    builder: (context, authFactory, child) {
                      return GradientButton(
                        text: 'Create Account',
                        onPressed: authFactory.isLoading ? null : _signup,
                        startColor: AppTheme.brightBlue,
                        endColor: AppTheme.brightPink,
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 14,
                        ),
                      ),
                      Consumer<AuthProviderFactory>(
                        builder: (context, authFactory, child) {
                          return GestureDetector(
                            onTap: authFactory.isLoading
                                ? null
                                : () => Navigator.pushReplacementNamed(
                                    context, '/login'),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                color: authFactory.isLoading
                                    ? Colors.grey
                                    : AppTheme.brightBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
