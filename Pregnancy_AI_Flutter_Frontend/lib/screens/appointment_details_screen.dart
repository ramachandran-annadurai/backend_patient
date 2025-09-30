import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  const AppointmentDetailsScreen({super.key});

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _cancelReasonController = TextEditingController();

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmall = screenSize.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeader(context, isSmall),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 12.0 : 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _doctorCard(isSmall),
                      const SizedBox(height: 16),
                      _infoTile(
                        icon: Icons.event,
                        title: 'Friday ,Sep 19, 2025',
                        subtitle: '11:30AM -12:00 AM',
                        isSmall: isSmall,
                      ),
                      const SizedBox(height: 12),
                      _infoTile(
                        icon: Icons.videocam_rounded,
                        title: 'Video Call',
                        subtitle:
                            'The Link will be active 15 minutes before the start time.',
                        isSmall: isSmall,
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('Preparation', isSmall),
                      const SizedBox(height: 8),
                      _paragraph(
                        'Please ensure you have a stable internet connection and are in a quiet, well-lit room. Keep your recent test results and a list of your current medications ready for discussion.',
                        isSmall,
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('My Notes', isSmall),
                      const SizedBox(height: 8),
                      _paragraph(
                        "I've been experiencing occasional chest tightness, especially in the mornings, and I would also like to discuss the side effects of my current medication.",
                        isSmall,
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('Waiting Room', isSmall),
                      const SizedBox(height: 8),
                      _waitingRoomStatus(isSmall),
                      const SizedBox(height: 16),
                      _actionButtons(isSmall),
                      SizedBox(height: isSmall ? 80.0 : 100.0),
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

  Widget _buildHeader(BuildContext context, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            size: isSmall ? 20.0 : 24.0,
            color: Colors.black87,
          ),
        ),
        Column(
          children: [
            Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: isSmall ? 18.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none,
            size: isSmall ? 20.0 : 24.0,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog() {
    final size = MediaQuery.of(context).size;
    final paddings = MediaQuery.of(context).padding;
    final bool isSmall = size.width < 360;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final double maxWidth = size.width - 32;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: size.height - paddings.top - paddings.bottom - 32,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(bottom: paddings.bottom + 16, top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            fontSize: isSmall ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(dialogContext),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.close, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Doctor header
                    Row(
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Dr. Emily Carter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Obstetrician', style: TextStyle(color: AppTheme.textGray)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Date & time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLightBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.event, color: AppTheme.brightBlue, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Tuesday, 24 Oct'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLightPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.schedule, color: Colors.blue, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text('09:00 AM'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.videocam_rounded, color: Colors.green, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text('Tele-appointment'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: isSmall ? 14 : 16)),
                    const SizedBox(height: 6),
                    const Text(
                      'Cancelling this appointment cannot be undone. The Doctor will be notified.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    const Text('Reason for cancellation (Optional)', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.lightGray),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _cancelReasonController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Unforeseen emergency...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushNamed(context, '/appointment-cancelled');
                        },
                        child: const Text('✖  Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      text: 'Keep Appointment',
                      startColor: AppTheme.brightBlue,
                      endColor: AppTheme.brightPink,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _doctorCard(bool isSmall) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                const Text(
                  'Obstetrician',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSmall,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.brightBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _paragraph(String text, bool isSmall) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall ? 13 : 14,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }

  Widget _waitingRoomStatus(bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Waiting Room Status',
          style: TextStyle(color: Colors.black54),
        ),
        const Text(
          'Open',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _actionButtons(bool isSmall) {
    return Column(
      children: [
        // Join Call - centered small pill button
        Center(child: _smallJoinButton(isSmall: isSmall)),
        const SizedBox(height: 12),
        // Bottom row: Cancel (left) and Reschedule (right)
        Row(
          children: [
            Expanded(
              child: _dangerAction(
                label: 'Cancel',
                icon: Icons.cancel_outlined,
                onPressed: _showCancelDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: GradientButton(
                  text: 'Reschedule',
                  startColor: AppTheme.brightBlue,
                  endColor: AppTheme.brightPink,
                  onPressed: () => Navigator.pushNamed(context, '/reschedule-appointment'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallJoinButton({required bool isSmall}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 44,
        width: isSmall ? 200 : 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.brightBlue, AppTheme.brightBlue.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.video_call_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Join Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _filledAction({
    required String label,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlinedAction({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.blue),
        label: Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.blue.shade200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dangerAction({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}


