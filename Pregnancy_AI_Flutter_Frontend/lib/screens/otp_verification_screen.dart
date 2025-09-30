import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_factory.dart';
import '../utils/constants.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/otp_input_field.dart';
import '../theme/app_theme.dart';
import '../models/otp_model.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String role;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Timer functionality
  Timer? _timer;
  int _timeLeft = 300; // 5 minutes in seconds
  bool get isTimerActive => _timeLeft > 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus the first OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 300; // Reset to 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get formattedTime {
    final minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    print('🔍 OTP changed at index $index: "$value"');
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authFactory =
        Provider.of<AuthProviderFactory>(context, listen: false);
    bool success = false;

    // Use appropriate auth provider based on role
    if (widget.role == 'patient') {
      final otpModel = OtpModel(
        email: widget.email,
        otp: _otpCode,
      );
      success = await authFactory.patient.verifyOtp(otpModel);
    } else if (widget.role == 'doctor') {
      success = await authFactory.doctor.verifyOtp(
        email: widget.email,
        otp: _otpCode,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      if (widget.role == 'doctor') {
        Navigator.pushReplacementNamed(context, '/doctor-profile-completion');
      } else {
        Navigator.pushReplacementNamed(context, '/profile-completion');
      }
    } else if (mounted) {
      final cleanErrorMessage = _extractCleanErrorMessage(
          authFactory.error ?? 'OTP verification failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cleanErrorMessage),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (isTimerActive) return;

    final authFactory =
        Provider.of<AuthProviderFactory>(context, listen: false);
    bool success = false;

    // Use appropriate auth provider based on role
    if (widget.role == 'patient') {
      success = await authFactory.patient.resendOtp(
        email: widget.email,
      );
    } else if (widget.role == 'doctor') {
      success = await authFactory.doctor.resendOtp(
        email: widget.email,
      );
    }

    print('🔄 Resend OTP success: $success');

    if (success && mounted) {
      // Clear existing OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }

      // Restart timer
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully! Please check your email.'),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear current OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authFactory.error ?? 'Failed to resend OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                    'Verification',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGray,
                          fontSize: 28,
                        ),
                  ),

                  const SizedBox(height: 20),

                  // Instruction text
                  Text(
                    'Enter the OTP sent to your registered email\n${widget.email}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textGray,
                          fontSize: 16,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // OTP Input fields (6 digits)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return OTPInputField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        isFirst: index == 0,
                        isLast: index == 5,
                        onChanged: (value) => _onOtpChanged(value, index),
                      );
                    }),
                  ),

                  const SizedBox(height: 40),

                  // Verify button
                  Consumer<AuthProviderFactory>(
                    builder: (context, authFactory, child) {
                      return GradientButton(
                        text: 'Verify',
                        onPressed: authFactory.isLoading ? null : _verifyOtp,
                        startColor: AppTheme.brightBlue,
                        endColor: AppTheme.brightPink,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Timer section
                  Column(
                    children: [
                      Text(
                        'The Code Will Expire in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Resend OTP section
                  Column(
                    children: [
                      Text(
                        'Didn\'t receive the code?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textGray,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<AuthProviderFactory>(
                        builder: (context, authFactory, child) {
                          return GestureDetector(
                            onTap: (authFactory.isLoading || isTimerActive)
                                ? null
                                : _resendOtp,
                            child: Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: (authFactory.isLoading || isTimerActive)
                                    ? AppTheme.textGray.withOpacity(0.5)
                                    : AppTheme.brightBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
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
}
