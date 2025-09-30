import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 80,
                color: AppTheme.brightBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Appointments',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your appointment schedule will appear here',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGray.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
