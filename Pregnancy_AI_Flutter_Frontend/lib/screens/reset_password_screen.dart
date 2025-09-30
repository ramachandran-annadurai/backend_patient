import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/reset_password_provider.dart';
import '../models/reset_password_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // OTP Timer
  int _otpTimerSeconds = 60; // 1 minute timer
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  void _startOtpTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpTimerSeconds > 0) {
        setState(() {
          _otpTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    setState(() {
      _otpTimerSeconds = 60;
    });
    _startOtpTimer();
    // TODO: Implement resend OTP functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent to your email'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatTimer() {
    final minutes = _otpTimerSeconds ~/ 60;
    final seconds = _otpTimerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final resetPasswordProvider = context.read<ResetPasswordProvider>();

    // Create ResetPasswordModel from form data
    final resetPasswordModel = ResetPasswordModel(
      email: widget.email,
      otp: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    await resetPasswordProvider.resetPassword(resetPasswordModel);

    if (resetPasswordProvider.success && mounted) {
      Navigator.pushReplacementNamed(context, '/password-reset-successful');
    } else if (mounted && resetPasswordProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resetPasswordProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordProvider>(
      builder: (context, resetPasswordProvider, child) {
        return AppScaffold(
          body: SafeArea(
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Add some top spacing
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1),

                            // Title
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Instructions
                            Text(
                              'Please enter the OTP sent to your email &\nYour new password',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // OTP Input Field
                            CustomTextField(
                              controller: _otpController,
                              labelText: 'OTP',
                              hintText: 'Enter OTP',
                              prefixIcon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter OTP';
                                }
                                if (value.trim().length != 6) {
                                  return 'OTP must be 6 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // OTP Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'The Code Will Expire in ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                Text(
                                  _formatTimer(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.brightPink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Resend OTP
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive the code? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textGray,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      _otpTimerSeconds == 0 ? _resendOtp : null,
                                  child: Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _otpTimerSeconds == 0
                                          ? AppTheme.brightBlue
                                          : AppTheme.textGray.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // New Password Input Field
                            CustomTextField(
                              controller: _newPasswordController,
                              labelText: 'New Password',
                              hintText: 'New Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureNewPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNewPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm New Password Input Field
                            CustomTextField(
                              controller: _confirmPasswordController,
                              labelText: 'Confirm New Password',
                              hintText: 'Confirm New Password',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm new password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Reset Password Button with Gradient
                            GradientButton(
                              text: 'Reset Password',
                              onPressed: resetPasswordProvider.isLoading
                                  ? null
                                  : _resetPassword,
                              startColor: AppTheme.brightBlue,
                              endColor: AppTheme.brightPink,
                            ),
                            const SizedBox(height: 24),

                            // Back to Login
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Back to Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.brightBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Add bottom spacing to fill remaining space
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Back button positioned at top-left
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppTheme.textGray,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
