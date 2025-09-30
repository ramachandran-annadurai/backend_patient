import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';
import '../../widgets/app_background.dart';
import '../../theme/app_theme.dart';
import 'new_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentController>(context, listen: false)
          .getAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: AppTheme.brightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AppointmentController>(context, listen: false)
                  .getAppointments();
            },
          ),
        ],
      ),
      body: Consumer<AppointmentController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.getAppointments(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.getAppointments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.appointments.length,
              itemBuilder: (context, index) {
                final appointment = controller.appointments[index];
                return _buildAppointmentCard(appointment);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewAppointmentScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.brightBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.appointmentType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(appointment.status ?? 'pending'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatDate(appointment.appointmentDate),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  appointment.appointmentTime,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (appointment.patientNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.patientNotes}',
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (appointment.status == 'pending' ||
                    appointment.status == 'scheduled') ...[
                  TextButton(
                    onPressed: () => _showCancelDialog(appointment),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                ],
                TextButton(
                  onPressed: () => _showAppointmentDetails(appointment),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'scheduled':
        color = Colors.blue;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content:
            const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointment);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(AppointmentModel appointment) async {
    if (appointment.id == null) return;

    final controller =
        Provider.of<AppointmentController>(context, listen: false);
    final success = await controller.cancelAppointment(appointment.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.appointmentType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', _formatDate(appointment.appointmentDate)),
              _buildDetailRow('Time', appointment.appointmentTime),
              _buildDetailRow('Status', appointment.status ?? 'Unknown'),
              if (appointment.doctorId != null)
                _buildDetailRow('Doctor ID', appointment.doctorId!),
              if (appointment.notes?.isNotEmpty == true)
                _buildDetailRow('Notes', appointment.notes!),
              if (appointment.patientNotes?.isNotEmpty == true)
                _buildDetailRow('Your Notes', appointment.patientNotes!),
              if (appointment.createdAt != null)
                _buildDetailRow(
                    'Created', _formatDateTime(appointment.createdAt!)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
