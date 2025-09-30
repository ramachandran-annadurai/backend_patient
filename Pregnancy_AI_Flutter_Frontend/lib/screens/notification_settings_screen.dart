import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _allowNotifications = true;
  String _showPreviews = 'Always';

  bool _newMessages = true;
  bool _urgentAlerts = true;
  bool _upcomingAppointments = false;
  bool _labResults = true;

  bool _weeklySummary = true;
  bool _activityReports = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

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
                _sectionCard(
                  title: 'General',
                  children: [
                    _switchRow(
                      title: 'Allow Notifications',
                      value: _allowNotifications,
                      onChanged: (v) => setState(() => _allowNotifications = v),
                    ),
                    const Divider(height: 1),
                    _navRow(
                      title: 'Show Previews',
                      trailing: _showPreviews,
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _sectionCard(
                  title: 'Push Notifications',
                  subtitle: 'Select which events you want to be notified about.',
                  children: [
                    _iconSwitchRow(
                      icon: Icons.chat_bubble_outline,
                      iconBg: const Color(0xFFE9F2FF),
                      iconColor: const Color(0xFF6C63FF),
                      title: 'New Patient Messages',
                      subtitle: 'Get notified for new messages',
                      value: _newMessages,
                      onChanged: (v) => setState(() => _newMessages = v),
                    ),
                    const Divider(height: 1),
                    _iconSwitchRow(
                      icon: Icons.priority_high,
                      iconBg: const Color(0xFFFFE9E9),
                      iconColor: const Color(0xFFFF6B6B),
                      title: 'Urgent Alerts',
                      subtitle: 'High-priority notifications',
                      value: _urgentAlerts,
                      onChanged: (v) => setState(() => _urgentAlerts = v),
                    ),
                    const Divider(height: 1),
                    _iconSwitchRow(
                      icon: Icons.event_available_outlined,
                      iconBg: const Color(0xFFE8FFF3),
                      iconColor: const Color(0xFF2ECC71),
                      title: 'Upcoming Appointments',
                      subtitle: 'Reminders for appointments',
                      value: _upcomingAppointments,
                      onChanged: (v) => setState(() => _upcomingAppointments = v),
                    ),
                    const Divider(height: 1),
                    _iconSwitchRow(
                      icon: Icons.science_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9B59B6),
                      title: 'Lab Results Ready',
                      subtitle: 'When new results are available',
                      value: _labResults,
                      onChanged: (v) => setState(() => _labResults = v),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _sectionCard(
                  title: 'Email Notifications',
                  subtitle: 'Receive email summaries and alerts.',
                  children: [
                    _switchRow(
                      title: 'Weekly Summary',
                      value: _weeklySummary,
                      onChanged: (v) => setState(() => _weeklySummary = v),
                    ),
                    const Divider(height: 1),
                    _switchRow(
                      title: 'Patient Activity Reports',
                      value: _activityReports,
                      onChanged: (v) => setState(() => _activityReports = v),
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 20 : 24),
                _saveButton(size),
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
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
        const Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 24, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _sectionCard({required String title, String? subtitle, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _switchRow({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.brightBlue),
        ],
      ),
    );
  }

  Widget _navRow({required String title, required String trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(trailing, style: const TextStyle(color: Colors.black87)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _iconSwitchRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.brightBlue),
        ],
      ),
    );
  }

  Widget _saveButton(Size size) {
    return Center(
      child: Container(
        width: size.width - 80,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.brightBlue, AppTheme.brightPink]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: AppTheme.brightBlue.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
            child: const Center(
              child: Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}


