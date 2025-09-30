import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class PasswordResetSuccessfulScreen extends StatefulWidget {
  const PasswordResetSuccessfulScreen({super.key});

  @override
  State<PasswordResetSuccessfulScreen> createState() =>
      _PasswordResetSuccessfulScreenState();
}

class _PasswordResetSuccessfulScreenState
    extends State<PasswordResetSuccessfulScreen> {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Password Reset Successful!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGray,
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description Message
                Text(
                  'Your password has been updated. Please login with your new password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textGray,
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Return to Login button
                GradientButton(
                  text: "Return to Login",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  startColor: AppTheme.brightBlue,
                  endColor: AppTheme.brightPink,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
