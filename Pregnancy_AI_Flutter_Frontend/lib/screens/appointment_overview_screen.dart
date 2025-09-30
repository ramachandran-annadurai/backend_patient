import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class AppointmentOverviewScreen extends StatefulWidget {
  const AppointmentOverviewScreen({super.key});

  @override
  State<AppointmentOverviewScreen> createState() => _AppointmentOverviewScreenState();
}

class _AppointmentOverviewScreenState extends State<AppointmentOverviewScreen> {
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
                      _buildDoctorCard(),
                      const SizedBox(height: 16),
                      _buildSectionHeader("Today's Appointments", Icons.calendar_today),
                      const SizedBox(height: 8),
                      _buildAppointmentCard(),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Yesterday Appointments', null),
                      const SizedBox(height: 8),
                      _buildSimpleAppointmentTile(),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Past Appointments', null),
                      const SizedBox(height: 8),
                      _buildSimpleAppointmentTile(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GradientButton(
                text: 'Add New Appointment',
                startColor: AppTheme.brightBlue,
                endColor: AppTheme.brightPink,
                onPressed: () => Navigator.pushNamed(context, '/new-appointment'),
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

  Widget _buildDoctorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 28, backgroundColor: Colors.blueGrey),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Dr. Emily Carter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(height: 2),
              Text('Obstetrician', style: TextStyle(color: AppTheme.textGray)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData? trailingIcon) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87)),
        ),
        if (trailingIcon != null) Icon(trailingIcon, color: Colors.black87),
      ],
    );
  }

  Widget _buildAppointmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 50,
                  decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(10)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Text('09:00', style: TextStyle(color: Color(0xFF448AFF), fontWeight: FontWeight.w700)),
                    Text('AM', style: TextStyle(color: Color(0xFF448AFF))),
                  ]),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Jessica Alba'),
                    subtitle: Text('Tele-appointment'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Friday,\nSep 19, 2025')),
                _smallActionButton(context, Icons.event, 'Reschedule'),
                const SizedBox(width: 8),
                _smallActionButton(context, Icons.cancel_outlined, 'Cancel', danger: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallActionButton(BuildContext context, IconData icon, String label, {bool danger = false}) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: danger ? Colors.red : Colors.blue),
        label: Text(label, style: TextStyle(fontSize: 12, color: danger ? Colors.red : Colors.blue)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: danger ? Colors.red.shade200 : Colors.blue.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildSimpleAppointmentTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: _buildTimeBadge(),
        title: const Text('Jessica Alba'),
        subtitle: const Text('Tele-appointment'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Container(
      width: 56,
      height: 46,
      decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Text('09:00', style: TextStyle(color: Color(0xFF448AFF), fontWeight: FontWeight.w700)),
        Text('AM', style: TextStyle(color: Color(0xFF448AFF))),
      ]),
    );
  }
}

