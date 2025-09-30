import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';
import '../models/login_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdentifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    final loginModel = LoginRequestModel(
      loginIdentifier: _loginIdentifierController.text.trim(),
      password: _passwordController.text,
    );

    await loginProvider.login(loginModel);

    if (loginProvider.isLoggedIn && mounted) {
      final response = loginProvider.loginResponse!;

      if (widget.role == 'patient') {
        // Check if profile is complete for patients
        if (response.isProfileComplete) {
          Navigator.pushReplacementNamed(context, '/main-tabs');
        } else {
          Navigator.pushReplacementNamed(context, '/profile');
        }
      } else {
        // For doctors, navigate to doctor dashboard
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginProvider.error ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Welcome Back Mom',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

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
                  const SizedBox(height: 16),

                  // Password Input Field
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password Link (aligned to right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Consumer<LoginProvider>(
                      builder: (context, loginProvider, child) {
                        return TextButton(
                          onPressed: loginProvider.isLoading
                              ? null
                              : () {
                                  if (widget.role == 'doctor') {
                                    Navigator.pushNamed(
                                        context, '/doctor-forgot-password');
                                  } else {
                                    Navigator.pushNamed(
                                        context, '/forgot-password');
                                  }
                                },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: loginProvider.isLoading
                                  ? Colors.grey
                                  : AppTheme.brightBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Button with Gradient
                  Consumer<LoginProvider>(
                    builder: (context, loginProvider, child) {
                      return GradientButton(
                        text: 'Log In',
                        onPressed: loginProvider.isLoading ? null : _login,
                        startColor: AppTheme.brightBlue,
                        endColor: AppTheme.brightPink,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 16,
                        ),
                      ),
                      Consumer<LoginProvider>(
                        builder: (context, loginProvider, child) {
                          return TextButton(
                            onPressed: loginProvider.isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacementNamed(
                                        context, '/signup',
                                        arguments: widget.role);
                                  },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: loginProvider.isLoading
                                    ? Colors.grey
                                    : AppTheme.brightBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
