import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class AppointmentCancelledScreen extends StatefulWidget {
  const AppointmentCancelledScreen({super.key});

  @override
  State<AppointmentCancelledScreen> createState() => _AppointmentCancelledScreenState();
}

class _AppointmentCancelledScreenState extends State<AppointmentCancelledScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12.0 : 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isSmall),
                SizedBox(height: isSmall ? 24 : 32),
                _successBadge(isSmall),
                SizedBox(height: isSmall ? 12 : 16),
                _title(isSmall),
                SizedBox(height: isSmall ? 8 : 10),
                _subtitle(isSmall),
                SizedBox(height: isSmall ? 20 : 24),
                _appointmentCard(isSmall),
                SizedBox(height: isSmall ? 28 : 36),
                _backHomeButton(size),
                SizedBox(height: isSmall ? 80 : 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'Appointment Cancelled',
          style: TextStyle(
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(Icons.notifications_none, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _successBadge(bool isSmall) {
    return Column(
      children: [
        Container(
          width: isSmall ? 60 : 72,
          height: isSmall ? 60 : 72,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: Icon(Icons.check, color: Colors.green, size: isSmall ? 32 : 36),
        ),
        SizedBox(height: 12),
        Text(
          'Success!',
          style: TextStyle(
            fontSize: isSmall ? 20 : 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _title(bool isSmall) {
    return const SizedBox.shrink();
  }

  Widget _subtitle(bool isSmall) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'The appointment has been successfully\ncancelled.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textGray),
        ),
      ),
    );
  }

  Widget _appointmentCard(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isSmall ? 22 : 26,
                backgroundImage: const AssetImage('assets/images/doctor_placeholder.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Dr. Emily Carter',
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Obstetrician', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _chip(icon: Icons.event, text: 'Tuesday, 24 Oct', isSmall: isSmall),
              const SizedBox(width: 16),
              _chip(icon: Icons.access_time, text: '09:00 AM', isSmall: isSmall),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _chip(icon: Icons.videocam, text: 'Tele-appointment', isSmall: isSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({required IconData icon, required String text, required bool isSmall}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 16 : 18, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: isSmall ? 12 : 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _backHomeButton(Size size) {
    return Center(
      child: Container(
        width: size.width - 80,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.brightBlue, AppTheme.brightPink],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brightBlue.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pop(context),
            child: const Center(
              child: Text(
                'Back to Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


