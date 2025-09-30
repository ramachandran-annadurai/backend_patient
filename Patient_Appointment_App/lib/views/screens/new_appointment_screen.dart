import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/appointment_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/gradient_button.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  String _appointmentType = 'Follow-up';
  bool _isVideoCall = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 30);
  final TextEditingController _problemController = TextEditingController();

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

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
                      _buildDoctorCard(),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Type',
                        child: _buildTypeDropdown(),
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimeRow(),
                      const SizedBox(height: 16),
                      _buildAppointmentTypeSegment(),
                      const SizedBox(height: 16),
                      _buildProblemInput(),
                      const SizedBox(height: 24),
                      Consumer<AppointmentController>(
                        builder: (context, controller, child) {
                          return Center(
                            child: GradientButton(
                              text: controller.isLoading
                                  ? 'Scheduling...'
                                  : 'Schedule Appointment',
                              startColor: AppTheme.brightBlue,
                              endColor: AppTheme.brightPink,
                              onPressed: controller.isLoading
                                  ? null
                                  : _scheduleAppointment,
                              width: size.width - 80,
                              height: 48,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<AppointmentController>(
                        builder: (context, controller, child) {
                          if (controller.error != null) {
                            return _buildErrorWidget(controller.error!);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
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
          icon: Icon(Icons.arrow_back,
              size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            Text(
              'New Appointment',
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.more_horiz,
              size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
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
                Text('Dr. Emily Carter',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                SizedBox(height: 2),
                Text('Obstetrician',
                    style: TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppTheme.textGray)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTypeDropdown() {
    return InkWell(
      onTap: _showTypeSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(_appointmentType,
                    style: const TextStyle(color: Colors.black87))),
            const Icon(Icons.expand_more, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return _buildLabeledField(
      label: 'Date & Time',
      child: Row(
        children: [
          Expanded(
            child: _fieldButton(
              icon: Icons.calendar_today,
              label: AppDateUtils.formatDate(_selectedDate),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _fieldButton(
              icon: Icons.access_time,
              label: _selectedTime.format(context),
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGray),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentTypeSegment() {
    return _buildLabeledField(
      label: 'Appointment Type',
      child: Row(
        children: [
          Expanded(
            child: _segmentedButton(
              selected: _isVideoCall,
              icon: Icons.videocam,
              label: 'Video Call',
              onTap: () => setState(() => _isVideoCall = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _segmentedButton(
              selected: !_isVideoCall,
              icon: Icons.apartment,
              label: 'In-person',
              onTap: () => setState(() => _isVideoCall = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _segmentedButton(
      {required bool selected,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE9F2FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected ? Colors.transparent : AppTheme.lightGray),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.blue : Colors.black87, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.blue : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Write your problem',
            style: TextStyle(
                fontWeight: FontWeight.w600, color: AppTheme.textGray)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.lightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: _problemController,
            maxLines: 5,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'write your problem here...',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTypeSheet() async {
    final options = <String>[
      'Follow-up',
      'First Visit',
      'Report Review',
      'General',
      'Consultation',
      'Emergency',
      'Check-up',
      'Specialist'
    ];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((e) => ListTile(
                      title: Text(e),
                      onTap: () => Navigator.pop(context, e),
                    ))
                .toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _appointmentType = selected);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (result != null) {
      setState(() => _selectedTime = result);
    }
  }

  Future<void> _scheduleAppointment() async {
    final controller =
        Provider.of<AppointmentController>(context, listen: false);

    // Format date and time for API
    final appointmentDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final appointmentTime = _selectedTime.format(context);

    // Prepare appointment type with video call info
    String appointmentType =
        '$_appointmentType (${_isVideoCall ? 'Video Call' : 'In-person'})';

    final success = await controller.createAppointment(
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      appointmentType: appointmentType,
      patientNotes: _problemController.text.trim(),
      doctorId: 'DOC001',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
