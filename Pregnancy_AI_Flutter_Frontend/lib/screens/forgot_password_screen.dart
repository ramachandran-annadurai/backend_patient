import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/forgot_password_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController();
  String? _userEmail;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final forgotPasswordProvider =
        Provider.of<ForgotPasswordProvider>(context, listen: false);
    await forgotPasswordProvider
        .sendResetRequest(_loginIdentifierController.text.trim());

    if (forgotPasswordProvider.success && mounted) {
      setState(() {
        _userEmail = _loginIdentifierController.text.trim();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your email'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to reset password screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/reset-password',
            arguments: {'email': _userEmail},
          );
        }
      });
    } else if (mounted && forgotPasswordProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(forgotPasswordProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordProvider>(
      builder: (context, forgotPasswordProvider, child) {
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
                                    MediaQuery.of(context).size.height * 0.30),

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
                            const SizedBox(height: 40),

                            // Email Input Field
                            CustomTextField(
                              controller: _loginIdentifierController,
                              labelText: 'Email',
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value.trim())) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Send OTP Button with Gradient
                            GradientButton(
                              text: 'Send OTP',
                              onPressed: forgotPasswordProvider.isLoading
                                  ? null
                                  : _sendOtp,
                              startColor: AppTheme.brightBlue,
                              endColor: AppTheme.brightPink,
                            ),

                            // Add bottom spacing to fill remaining space
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2,
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
