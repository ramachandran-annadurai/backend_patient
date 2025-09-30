import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                Text(
                  'Welcome to the',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mom Care',
                  style: TextStyle(
                    fontSize: 36,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Moments of Wonder',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80),

                // Expecting Mother Button
                _buildRoleButton(
                  context,
                  title: 'Expecting Mother',
                  icon: Icons.pregnant_woman,
                  gradientColors: [
                    AppTheme.brightPink,
                    AppTheme.brightPink.withOpacity(0.8)
                  ],
                  onTap: () => Navigator.pushNamed(context, '/login',
                      arguments: 'patient'),
                ),
                const SizedBox(height: 24),

                // Healthcare Provider Button
                _buildRoleButton(
                  context,
                  title: 'Healthcare Provider',
                  icon: Icons.medical_services,
                  gradientColors: [
                    AppTheme.brightBlue,
                    AppTheme.brightBlue.withOpacity(0.8)
                  ],
                  onTap: () => Navigator.pushNamed(context, '/login',
                      arguments: 'doctor'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
