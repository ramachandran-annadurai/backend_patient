import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class AppointmentConfirmationScreen extends StatefulWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  State<AppointmentConfirmationScreen> createState() => _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState extends State<AppointmentConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddings = MediaQuery.of(context).padding;
    final bool isSmall = size.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeaderBar(isSmall),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - paddings.top - paddings.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      _buildSuccessIcon(),
                      const SizedBox(height: 24),
                      _buildTitle(),
                      const SizedBox(height: 12),
                      _buildSubtitle(),
                      const SizedBox(height: 28),
                      
                      const SizedBox(height: 12),
                      Center(
                        child: GradientButton(
                          text: 'View Details',
                          startColor: AppTheme.brightBlue,
                          endColor: AppTheme.brightPink,
                          onPressed: () => Navigator.pushNamed(context, '/appointment-details'),
                          width: size.width - 80,
                          height: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/new-appointment'),
                          child: const Text('Edit your appointment'),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        const Text('Appointment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.withOpacity(0.1),
          border: Border.all(color: Colors.green, width: 4),
        ),
        child: const Icon(Icons.check, color: Colors.green, size: 44),
      ),
    );
  }

  Widget _buildTitle() {
    return const Center(
      child: Text(
        'Your Appointment\nConfirmed!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'You booked an appointment with Dr.\nPediatrician Purpersion on February 21,\nat 02:00 PM',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textGray,
        ),
      ),
    );
  }
}


