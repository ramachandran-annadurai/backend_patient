import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  const RescheduleAppointmentScreen({super.key});

  @override
  State<RescheduleAppointmentScreen> createState() => _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState extends State<RescheduleAppointmentScreen> {
  final List<String> _types = const ['Follow-Up', 'Consultation', 'Routine'];
  String _selectedType = 'Follow-Up';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  bool _isVideo = true;
  final TextEditingController _problemController = TextEditingController();

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

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
                SizedBox(height: isSmall ? 16 : 20),
                _doctorCard(isSmall),
                SizedBox(height: isSmall ? 16 : 20),
                _sectionLabel('Type'),
                SizedBox(height: 8),
                _typeDropdown(isSmall),
                SizedBox(height: 16),
                _sectionLabel('Date & Time'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _dateField(isSmall)),
                    const SizedBox(width: 12),
                    Expanded(child: _timeField(isSmall)),
                  ],
                ),
                SizedBox(height: 16),
                _sectionLabel('Appointment Type'),
                SizedBox(height: 8),
                _appointmentTypeSwitch(isSmall),
                SizedBox(height: 16),
                _sectionLabel('Write your problem'),
                SizedBox(height: 8),
                _problemField(isSmall),
                SizedBox(height: isSmall ? 20 : 24),
                _submitButton(size),
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
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
        Text(
          'Reschedule Appointment',
          style: TextStyle(
            fontSize: isSmall ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _doctorCard(bool isSmall) {
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
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmall ? 22 : 26,
            backgroundImage: const AssetImage('assets/images/doctor_placeholder.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Dr. Emily Carter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 4),
                Text('Obstetrician', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _typeDropdown(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _types
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _selectedType = v ?? _selectedType),
          isExpanded: true,
          style: TextStyle(fontSize: isSmall ? 14 : 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _dateField(bool isSmall) {
    final String label = _selectedDate.toLocal().toString().split(' ').first;
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: _iconField(
        isSmall: isSmall,
        icon: Icons.calendar_today,
        text: label,
      ),
    );
  }

  Widget _timeField(bool isSmall) {
    final String label = _selectedTime.format(context);
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      child: _iconField(
        isSmall: isSmall,
        icon: Icons.access_time,
        text: label,
      ),
    );
  }

  Widget _iconField({required bool isSmall, required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          Icon(icon, size: isSmall ? 18 : 20, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isSmall ? 14 : 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentTypeSwitch(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _toggleButton(
              selected: _isVideo,
              label: 'Video Call',
              icon: Icons.videocam,
              onTap: () => setState(() => _isVideo = true),
            ),
          ),
          Expanded(
            child: _toggleButton(
              selected: !_isVideo,
              label: 'In-person',
              icon: Icons.apartment,
              onTap: () => setState(() => _isVideo = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({required bool selected, required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.backgroundLightBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppTheme.brightBlue : Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.brightBlue : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _problemField(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGray),
      ),
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _problemController,
        maxLines: 5,
        decoration: const InputDecoration(
          isCollapsed: true,
          hintText: 'write your problem here...',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: isSmall ? 14 : 16),
      ),
    );
  }

  Widget _submitButton(Size size) {
    return Center(
      child: Container(
        width: size.width - 80,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.brightBlue, AppTheme.brightPink]),
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
            onTap: () {},
            child: const Center(
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


