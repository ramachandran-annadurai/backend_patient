import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
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
                      const SizedBox(height: 12),
                      _buildProfileCard(),
                      const SizedBox(height: 16),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 16),
                      _buildPreviousRecordsSection(),
                      const SizedBox(height: 16),
                      _buildLabResultsSection(),
                      const SizedBox(height: 16),
                      _buildVitalResultsSection(),
                      const SizedBox(height: 20),
                      _buildUploadButton(),
                      const SizedBox(height: 20),
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
        Column(
          children: [
            Text(
              'Medical Records',
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              AppDateUtils.getCurrentDate(),
              style: TextStyle(fontSize: isSmall ? 12 : 14, color: Colors.grey[600]),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(BorderSide(color: AppTheme.lightGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfileCard() {
    return _buildCardContainer(
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Jessica Alba', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                SizedBox(height: 4),
                Text('Patient ID: 123456', style: TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search records...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _filterChip('Date'),
              const SizedBox(width: 8),
              _filterChip('Type'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textGray)),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more, color: AppTheme.textGray, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousRecordsSection() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Previous Medical Records', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          _recordTile(color: Colors.blue, icon: Icons.assignment_turned_in, title: 'Annual Check-up', subtitle: 'Dr. Strange | 12/05/2023', trailing: Icons.download),
          const SizedBox(height: 10),
          _recordTile(color: Colors.pink, icon: Icons.assignment, title: 'Allergy Test Results', subtitle: 'Dr. Banner | 02/03/2023', trailing: Icons.download),
        ],
      ),
    );
  }

  Widget _recordTile({required Color color, required IconData icon, required String title, required String subtitle, IconData? trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          if (trailing != null) Icon(trailing, color: AppTheme.textGray),
        ],
      ),
    );
  }

  Widget _buildLabResultsSection() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lab Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          _labTile(color: Colors.purple, icon: Icons.science, title: 'Blood Test', subtitle: 'Quest Diagnostics | 15/06/2024', trailing: Icons.remove_red_eye_outlined),
          const SizedBox(height: 10),
          _labTile(color: Colors.amber, icon: Icons.biotech, title: 'Genetic Screening', subtitle: 'Genesis Labs | 10/06/2024', trailing: Icons.remove_red_eye_outlined),
        ],
      ),
    );
  }

  Widget _labTile({required Color color, required IconData icon, required String title, required String subtitle, IconData? trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          if (trailing != null) Icon(trailing, color: AppTheme.textGray),
        ],
      ),
    );
  }

  Widget _buildVitalResultsSection() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vital Test Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 12),
          _vitalTile(color: Colors.pink, icon: Icons.monitor_heart, title: 'Fetal Heart Rate', subtitle: 'Last checked: 20/06/2024'),
          const SizedBox(height: 10),
          _vitalTile(color: Colors.green, icon: Icons.bloodtype, title: 'Blood Pressure', subtitle: 'Last checked: 20/06/2024'),
        ],
      ),
    );
  }

  Widget _vitalTile({required Color color, required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textGray),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: GradientButton(
        text: 'Upload Reports',
        startColor: AppTheme.brightBlue,
        endColor: AppTheme.brightPink,
        onPressed: () {
          Navigator.pushNamed(context, '/upload-document');
        },
      ),
    );
  }
}


