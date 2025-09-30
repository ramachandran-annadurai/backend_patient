import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
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
                      _buildProfileHeader(),
                      const SizedBox(height: 16),
                      _buildSectionTitle(Icons.medication, 'Medicine'),
                      const SizedBox(height: 8),
                      _buildMedicineCard(),
                      const SizedBox(height: 16),
                      _buildSectionTitle(Icons.warning_amber_rounded, 'Symptoms'),
                      const SizedBox(height: 8),
                      _buildSymptomCard(title: 'High Blood Pressure', subtitle: 'Systolic > 140 mmHg', trailing: 'Yesterday'),
                      const SizedBox(height: 10),
                      _buildSymptomCard(title: 'Severe Headache', subtitle: 'Reported twice today', trailing: '2h ago'),
                      const SizedBox(height: 16),
                      _buildSectionTitle(Icons.event_available, 'Appointments'),
                      const SizedBox(height: 8),
                      _buildAppointmentAlertCard(),
                      const SizedBox(height: 24),
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
        const Text('Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Stack(children: [
          const CircleAvatar(radius: 24, backgroundColor: Colors.orange),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          ),
        ]),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Jessica Alba', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 2),
          Text('Patient ID: 123456', style: TextStyle(color: AppTheme.textGray)),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  Widget _buildMedicineCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD6E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Folic Acid', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                  SizedBox(height: 4),
                  Text('Reminder to take daily dose', style: TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('8:00', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                Text('AM', style: TextStyle(color: AppTheme.textGray)),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.check_circle, color: Color(0xFFFF8AAE)),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCard({required String title, required String subtitle, required String trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Text(trailing, style: const TextStyle(color: Colors.black87)),
            const SizedBox(width: 12),
            const Icon(Icons.remove_red_eye_outlined, color: Color(0xFFFFC107)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentAlertCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8E4FF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Ultrasound\nAppointment', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                  SizedBox(height: 6),
                  Text('Dr. Strange', style: TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('Tomorrow', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.notifications, color: Color(0xFF6C63FF)),
          ],
        ),
      ),
    );
  }
}

