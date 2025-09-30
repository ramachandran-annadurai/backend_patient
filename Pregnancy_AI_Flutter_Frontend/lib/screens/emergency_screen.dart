import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
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
                _buildHeader(isSmall),
                SizedBox(height: isSmall ? 16 : 20),
                _sosBadge(isSmall),
                SizedBox(height: 8),
                _hintText(isSmall),
                SizedBox(height: isSmall ? 20 : 24),
                _sectionTitle('Critical Warnings', isSmall),
                SizedBox(height: 8),
                _criticalWarningCard(isSmall),
                SizedBox(height: isSmall ? 20 : 24),
                _sectionTitle('Emergency Contacts', isSmall),
                SizedBox(height: 8),
                _contactTile(
                  isSmall: isSmall,
                  leadingIcon: Icons.local_hospital,
                  title: 'Maternity Hospital',
                  subtitle: '(123) 456-7890',
                  iconColor: Colors.pink,
                ),
                SizedBox(height: 12),
                _contactTile(
                  isSmall: isSmall,
                  leadingIcon: Icons.person,
                  title: 'Dr. Emily Carter',
                  subtitle: 'Obstetrician',
                  iconColor: Colors.blue,
                ),
                SizedBox(height: 12),
                _contactTile(
                  isSmall: isSmall,
                  leadingIcon: Icons.family_restroom,
                  title: 'John Alba',
                  subtitle: 'Partner',
                  iconColor: Colors.deepPurple,
                ),
                SizedBox(height: 16),
                _addContactButton(isSmall),
                SizedBox(height: isSmall ? 20 : 24),
                _sectionTitle('Emergency Services', isSmall),
                SizedBox(height: 8),
                _ambulanceLocationButton(isSmall),
                SizedBox(height: isSmall ? 80 : 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back,
              size: isSmall ? 20 : 24, color: Colors.black87),
        ),
        Text(
          'Emergency',
          style: TextStyle(
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz,
              size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _sosBadge(bool isSmall) {
    return Column(
      children: [
        Container(
          width: isSmall ? 90 : 110,
          height: isSmall ? 90 : 110,
          decoration: const BoxDecoration(
            color: Color(0xFFFF4D4D),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 28 : 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hintText(bool isSmall) {
    return const Center(
      child: Text(
        'Press and hold to call emergency\nservices',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isSmall) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isSmall ? 16 : 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _criticalWarningCard(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border(left: BorderSide(color: Colors.red.shade300, width: 3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.monitor_heart, color: Colors.red.shade400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'High Blood Pressure Detected',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text(
                  '160/100 mmHg. Please contact your doctor\nimmediately.',
                  style: TextStyle(color: AppTheme.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactTile({
    required bool isSmall,
    required IconData leadingIcon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
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
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(leadingIcon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          _callButton(isSmall),
        ],
      ),
    );
  }

  Widget _callButton(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.phone,
          color: AppTheme.brightBlue, size: isSmall ? 18 : 20),
    );
  }

  Widget _addContactButton(bool isSmall) {
    return DottedBorder(
      radius: const Radius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppTheme.lightGray, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle_outline, color: Colors.black54),
            SizedBox(width: 8),
            Text('Add New\nContact',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _ambulanceLocationButton(bool isSmall) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(context, '/ambulance-location');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital, color: Colors.red),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambulance Location',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 2),
                      Text('Find nearest ambulance services',
                          style: TextStyle(color: AppTheme.textGray)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on,
                      color: AppTheme.brightBlue, size: isSmall ? 18 : 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Simple dotted border painter so we don't add dependencies
class DottedBorder extends StatelessWidget {
  final Widget child;
  final Radius radius;
  const DottedBorder(
      {super.key, required this.child, this.radius = const Radius.circular(8)});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(radius),
      child: CustomPaint(
        painter: _DottedRectPainter(),
        child: child,
      ),
    );
  }
}

class _DottedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.lightGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double dashWidth = 4.0;
    const double dashSpace = 3.0;
    final RRect rrect = RRect.fromLTRBR(
        0, 0, size.width, size.height, const Radius.circular(12));
    final Path path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final Path extract = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
